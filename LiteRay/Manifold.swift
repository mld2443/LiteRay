import Foundation
import simd

public class Manifold {
	internal var faces = [Face]()
	internal var edges = [Edge]()
	internal var vertices = [Vertex]()
	internal var halfedges = [Halfedge]()
	internal var AABB = (min: float3(), max: float3())
	
	lazy var center: float3 = {
		return mix(self.AABB.min, self.AABB.max, t: 0.5)
	}()
	
	internal var edgeHash = [Int: Edge]()
	
	public lazy var valid: Bool = {
		for vertex in self.vertices {
			if vertex.he == nil {
				return false
			}
			if vertex.he!.o != vertex {
				return false
			}
		}
		
		for face in self.faces {
			if face.he == nil {
				return false
			}
			
			var edge = face.he!
			
			repeat {
				if edge.f != face {
					return false
				}
				
				edge = edge.next!
			} while edge != face.he!
		}
		
		for halfedge in self.halfedges {
			if halfedge.next == nil {
				return false
			}
			if halfedge.prev == nil {
				return false
			}
			if halfedge.flip == nil {
				return false
			}
			if halfedge.flip!.flip! != halfedge {
				return false
			}
		}
		
		for edge in self.edges {
			if edge.he == nil {
				return false
			}
			if edge.he!.e != edge {
				return false
			}
			if edge.he!.flip!.e != edge {
				return false
			}
		}
		
		return true
	}()
	
	public init?(path: String, scale: Float = 1.0) {
		let stream = StreamReader(path: path)
		
		// iterate through the file and add in vertices and faces
		while let line = stream?.nextLine() {
			// check if the line is a comment
			if line.hasPrefix("#") {
			}
				
			// Check for vertices
			else if line.hasPrefix("v ") {
				let start = line.startIndex.advancedBy(1), end = line.endIndex
				let values = line[start..<end].trim.componentsSeparatedByString(" ").map({ Float($0)! })
				
				assert(values.count == 3)
				
				let x = values[0] * scale, y = values[1] * scale, z = values[2] * scale
				
				if x < AABB.min.x {
					AABB.min.x = x
				} else if x > AABB.max.x {
					AABB.max.x = x
				}
				
				if y < AABB.min.y {
					AABB.min.y = y
				} else if y > AABB.max.y {
					AABB.max.y = y
				}
				
				if z < AABB.min.z {
					AABB.min.z = z
				} else if z > AABB.max.z {
					AABB.max.z = z
				}
				
				vertices.append(Vertex(pos: float3(x, y, z)))
			}
				
			// Check for faces
			else if line.hasPrefix("f ") {
				var vertexList = [Vertex]()
				let start = line.startIndex.advancedBy(1), end = line.endIndex
				let indices = line[start..<end].trim.componentsSeparatedByString(" ").map({ Int($0)! - 1 })
				
				for index in indices {
					vertexList.append(vertices[index])
				}
				
				addFace(vertexList)
			}
		}
		
		stream?.close()
		
		if stream == nil {
			return nil
		}
	}
	
	public func centerAABB() {
		for vertex in vertices {
			vertex.pos = vertex.pos - center
		}
	}
	
	internal func addFace(vertexList: [Vertex]) {
		func getEdge(v1: Vertex, _ v2: Vertex) -> Edge {
			let hashValue = v1.hashValue ^ v2.hashValue
			
			if let edge = edgeHash[hashValue] {
				return edge
			}
			
			edges.append(Edge())
			edgeHash[hashValue] = edges.last!
			
			return edges.last!
		}
		
		let rotatedList: [Vertex] = vertexList.dropFirst() + [vertexList.first!]
		
		faces.append(Face())
		
		var first: Halfedge?, prev: Halfedge?
		
		for (this, next) in zip(vertexList, rotatedList) {
			let e = getEdge(this, next)
			
			halfedges.append(Halfedge(f: faces.last!, e: e, o: this, prev: prev, flip: e.he))
			
			if this != vertexList.first! {
				prev!.next = halfedges.last!
			}
			
			if e.he != nil {
				e.he!.flip = halfedges.last!
			}
			
			prev = halfedges.last
			e.he = prev!
			
			if this == vertexList.first! {
				first = prev
			}
			
			prev!.o.he = prev
		}
		
		prev!.next = first
		faces.last!.he = halfedges.last
		first!.prev = halfedges.last
	}
	
	/// Adapted from [tavianator.com](https://tavianator.com/fast-branchless-raybounding-box-intersections/)
	public func intersectAABB(r: Ray, frustrum: ClosedInterval<Float>) -> Bool {
		let tx1 = (AABB.min.x - r.o.x) * r.inv.x
		let tx2 = (AABB.max.x - r.o.x) * r.inv.x
		
		var tmin = min(tx1, tx2)
		var tmax = max(tx1, tx2)
		
		let ty1 = (AABB.min.y - r.o.y) * r.inv.y
		let ty2 = (AABB.max.y - r.o.y) * r.inv.y
		
		tmin = max(tmin, min(ty1, ty2))
		tmax = min(tmax, max(ty1, ty2))
		
		let tz1 = (AABB.min.z - r.o.z) * r.inv.z
		let tz2 = (AABB.max.z - r.o.z) * r.inv.z
		
		tmin = max(tmin, min(tz1, tz2))
		tmax = min(tmax, max(tz1, tz2))
		
		if !(frustrum ~= tmin) && !(frustrum ~= tmax) {
			return false
		}
		
		return tmax >= tmin
	}
	
	public func intersectRay(r: Ray, frustrum: ClosedInterval<Float>) -> float4? {
		if !intersectAABB(r, frustrum: frustrum) {
			return nil
		}
		
		var closest: float4?
		
		for face in faces {
			if let collision = face.intersectRay(r) {
				if frustrum ~= collision && collision < closest?.w ?? Float.infinity {
					let normal = face.normal
					closest = float4(normal.x, normal.y, normal.z, collision)
				}
			}
		}
		
		return closest
	}
}

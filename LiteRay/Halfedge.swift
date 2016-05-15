//
//  Halfedge.swift
//  LiteRay
//
//  Created by Matthew Dillard on 3/12/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation
import simd

public class Halfedge : NSObject {
	var next: Halfedge?, prev: Halfedge?, flip: Halfedge?
	var f: Face
	var e: Edge
	var o: Vertex
	
	public lazy var p: float3 = self.o.pos
	
	public init(f: Face, e: Edge, o: Vertex, next: Halfedge? = nil, prev: Halfedge? = nil, flip: Halfedge? = nil) {
		self.f = f
		self.e = e
		self.o = o
		self.next = next
		self.prev = prev
		self.flip = flip
	}
}

public class Vertex : NSObject {
	var pos: float3
	var he: Halfedge?
	
	public init(pos: float3) {
		self.pos = pos
	}
	
	public lazy var neighborhood: [Vertex] = {
		var neighbors = [Vertex]()
		
		var trav = self.he!
		repeat {
			neighbors.append(trav.flip!.o)
			trav = trav.flip!.next!
		} while trav != self.he!
		
		return neighbors
	}()
	
	public lazy var valence: Int = self.neighborhood.count
}

public class Edge : NSObject {
	var he: Halfedge?
	
	public var midpoint: float3 {
		return mix(he!.p, he!.flip!.p, t: 0.5)
	}
}

public class Face : NSObject {
	var he: Halfedge?
	
	public lazy var centroid: float3 = {
		var center = float3()
		
		var trav = self.he!
		repeat {
			center += trav.p
			trav = trav.next!
		} while trav != self.he!
		
		return center
	}()
	
	public lazy var normal: float3 = ((self.he!.next!.next!.p - self.he!.p) ⨯ (self.he!.prev!.p - self.he!.next!.p)).unit
	
	public lazy var vetices: [Vertex] = {
		var neighbors = [Vertex]()
		
		var trav = self.he!
		repeat {
			neighbors.append(trav.o)
			trav = trav.next!
		} while trav != self.he!
		
		return neighbors
	}()
	
	/// - note: This is only guaranteed to work on convex polygons
	public func intersectRay(r: Ray) -> Float? {
		// Check for parallel line/plane intersection
		let quotient = r.d • normal
		if quotient == 0.0 {
			return nil
		}
		
		// Check if the plane is behind the ray
		let dist = ((he!.p - r.o) • normal) / quotient
		if dist <= 0 {
			return nil
		}
		
		// Calculate the intersection
		let intersect = (r * dist).o
		
		var lastSign = float3()
		var trav = he!
		repeat {
			let edgeVector = ((trav.next!.p) - (trav.p))
			let pointVector = (intersect - trav.p)
			let crossProductSign = sign(edgeVector ⨯ pointVector)
			
			if crossProductSign != float3(0,0,0) {
				if trav != he! && crossProductSign != lastSign {
					return nil
				}
				
				lastSign = crossProductSign
			}
			
			trav = trav.next!
		} while trav != he!
		
		return dist
	}
}

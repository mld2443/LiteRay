//
//  Mesh.swift
//  LiteRay
//
//  Created by Matthew Dillard on 3/12/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation
import simd

/// Manifold shape, describes triangular mesh surfaces
public class Mesh : Shape {
	public var material: Material
	public var position: float3
	public let manifold: Manifold
	
	public var normTransform: ((Intersection) -> Intersection)?
	
	/// Initializes a quadric
	/// - Parameters:
	///   - ColorData: Phong shading description
	///   - float3: point of origin for the quadric
	///   - Equation: equation of the quadric shape
	public init?(material: Material, position: float3, path: String, scale: Float = 1.0) {
		self.material = material
		self.position = position
		
		let manifold = Manifold(path: path, scale: scale)
		if manifold == nil {
			return nil
		}
		
		self.manifold = manifold!
	}
	
	/// Calculates a ray intersection with the mesh
	/// - Parameters:
	///   - Ray: the ray upon which to test intersection
	/// - Returns: the shortest distance along that ray to intersection or `nil` if there is no intersection
	public func intersectRay(r: Ray, frustrum: ClosedInterval<Float>) -> Intersection? {
		guard let depth = manifold.intersectRay(Ray(o:r.o - position , d:r.d), frustrum: frustrum) else {
			return nil
		}
		
		let point = (r * depth.w).o
		
		let intersect = Intersection(dist: depth.w, point: point, norm: float3(depth.x, depth.y, depth.z), material: self.material)
		
		return normTransform?(intersect) ?? intersect
	}
}

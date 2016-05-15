//
//  Shape.swift
//  LiteRay
//
//  Created by Matthew Dillard on 3/12/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Cocoa
import simd

public struct Intersection {
	public let dist: Float
	public let point: float3
	public let norm: float3
	public let material: Material
	
	public init(dist: Float = 0.0, point: float3 = float3(), norm: float3 = float3(), material: Material = Lambertian()) {
		self.dist = dist
		self.point = point
		self.norm = norm
		self.material = material
	}
}


public protocol Shape : class {
	var material: Material { get set }
	var position: float3 { get set }
	
	var normTransform: ((Intersection) -> Intersection)? { get set }
	
	func intersectRay(ray: Ray, frustrum: ClosedInterval<Float>) -> Intersection?
}

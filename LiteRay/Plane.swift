//
//  Plane.swift
//  LiteRay
//
//  Created by Matthew Dillard on 3/12/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation
import simd

/// Plane shape
///
/// The simplest of all shapes
public class Plane : Shape {
	public var material: Material
	public var position: float3
	
	public var normTransform: ((Intersection) -> Intersection)?
	
	private var normalVector: float3
	private var EQconstant: Float
	
	public var normal: float3 {
		get {
			return normalVector
		}
		set {
			normalVector = newValue.unit
			EQconstant = normalVector • position
		}
	}
	
	/// Initializes a plane
	/// - Parameters:
	///   - ColorData Phong shading description
	///   - Vector3 position of any point on the surface
	///   - Vector3 normal of the surface
	public init(material: Material, position: float3, normal: float3) {
		self.material = material
		self.position = position
		self.normalVector = normal.unit
		self.EQconstant = normalVector • position
	}
	
	public func intersectRay(ray: Ray, frustrum: (near: Float, far: Float)) -> Intersection? {
		let quotient = normal • ray.d
		
		if quotient == 0.0 {
			return nil
		}
		
		let dist = (EQconstant - normal • ray.o) / quotient
		
		if dist < frustrum.far && dist > frustrum.near {
			let point = (ray * dist).o
			
			let intersect = Intersection(dist: dist, point: point, norm: normalVector, material: material)
			
			if normTransform != nil {
				return normTransform!(intersect)
			}
			
			return intersect
		}
		
		return nil
	}
}

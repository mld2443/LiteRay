//
//  Sphere.swift
//  LiteRay
//
//  Created by Matthew Dillard on 3/12/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation
import simd

/// Sphere shape, implemented as a quadric
public class Sphere : Quadric {
	public init?(material: Material, position: float3, radius: Float) {
		super.init(material: material, position: position, equation: Equation(A: 1, B: 1, C: 1, J: -(radius * radius)))
		
		if radius <= 0 {
			return nil
		}
	}
	
	/// - note: works for any point (minus the center of the sphere)
	/// - remark: this function overrides the quadric function as it is simpler
	override internal func getNormal(at point: float3) -> float3 {
		let actual = (point - position).unit
		
		//let u: Float = 0.5 + (atan2f(actual.z, actual.x) / 2 * Float(M_PI))
		//let v: Float = 0.5 + (asinf(actual.y) / Float(M_PI))
		
		//let julia = juliaSet(float2(u,v), c: float2(-0.7,0.4))
		
		return actual
	}
}

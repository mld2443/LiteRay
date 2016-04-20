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
	public init?(colors: ColorData, position: float3, radius: Float) {
		super.init(colors: colors, position: position, equation: Equation(A: 1, B: 1, C: 1, J: -(radius * radius)))
		
		if radius <= 0 {
			return nil
		}
	}
	
	/// - note: works for any point (minus the center of the sphere)
	/// - remark: this function overrides the quadric function as it is simpler
	override internal func getNormal(at point: float3) -> float3 {
		return (point - position).unit
	}
}

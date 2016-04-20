//
//  Cylinder.swift
//  LiteRay
//
//  Created by Matthew Dillard on 3/12/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation
import simd

/// Cylinder shape, implemented as a quadric
/// - todo: make this rotatable so it is not always a vertical cylinder
public class Cylinder : Quadric {
	public init?(colors: ColorData, position: float3, xy_radius: Float) {
		super.init(colors: colors, position: position, equation: Equation(A: 1, B: 1, J: -(xy_radius * xy_radius)))
		
		if xy_radius <= 0 {
			return nil
		}
	}
	
	public init?(colors: ColorData, position: float3, xz_radius: Float) {
		super.init(colors: colors, position: position, equation: Equation(A: 1, C: 1, J: -(xz_radius * xz_radius)))
		
		if xz_radius <= 0 {
			return nil
		}
	}
	
	public init?(colors: ColorData, position: float3, yz_radius: Float) {
		super.init(colors: colors, position: position, equation: Equation(B: 1, C: 1, J: -(yz_radius * yz_radius)))
		
		if yz_radius <= 0 {
			return nil
		}
	}
}

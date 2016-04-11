//
//  Cylinder.swift
//  Trace
//
//  Created by Matthew Dillard on 3/12/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation
import simd

/// Cylinder shape, implemented as a quadric
/// - todo: make this rotatable so it is not always a vertical cylinder
public class Cylinder : Quadric {
	public init?(colors: ColorData, position: double3, radius: Double) {
		super.init(colors: colors, position: position, equation: Equation(A: 1,B: 0,C: 1,D: 0,E: 0,F: 0,G: 0,H: 0,I: 0,J: -(radius * radius)))
		
		if radius <= 0 {
			return nil
		}
	}
}

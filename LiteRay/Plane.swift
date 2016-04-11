//
//  Plane.swift
//  Trace
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
	public var colors: ColorData
	public var position: double3
	
	private var normalVector: double3
	private var EQconstant: Double
	
	public var normal: double3 {
		get {
			return normalVector
		}
		set {
			normalVector = newValue
			EQconstant = newValue • position
		}
	}
	
	/// Initializes a plane
	/// - Parameters:
	///   - ColorData Phong shading description
	///   - Vector3 position of any point on the surface
	///   - Vector3 normal of the surface
	public init(colors: ColorData, position: double3, normal: double3) {
		self.colors = colors
		self.position = position
		self.normalVector = normal.unit
		self.EQconstant = normalVector • position
	}
	
	public func getNormal(at point: double3) -> double3 {
		return normalVector
	}
	
	public func intersectRay(ray: Ray) -> Double {
		return (EQconstant - normal • ray.o) / (normal • ray.d)
	}
}

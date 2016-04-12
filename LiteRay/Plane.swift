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
	public var colors: ColorData
	public var position: float3
	public var refrIndex: Float
	
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
	public init(colors: ColorData, position: float3, normal: float3, refrIndex: Float = 1.0) {
		self.colors = colors
		self.position = position
		self.normalVector = normal.unit
		self.EQconstant = normalVector • position
		self.refrIndex = refrIndex
	}
	
	public func getNormal(at point: float3) -> float3 {
		return normalVector
	}
	
	public func intersectRay(ray: Ray) -> Float {
		return (EQconstant - normal • ray.o) / (normal • ray.d)
	}
}

//
//  float3.swift
//  LiteRay
//
//  Created by Matthew Dillard on 3/12/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation
import simd

extension float3: Equatable, CustomStringConvertible {
	
	public var description: String { return String(format: "(%.2f, %.2f, %.2f)", x, y, z) }
	
	/// Absolute value of a Vector
	/// - Returns: √(x² + y² + z²)
	public var length: Float {
		return simd.length(self)
	}
	
	/// Normalizes a vector
	/// - Returns: unit length vector
	public var unit: float3 {
		return normalize(self)
	}
}

public func /(lhs: float3, rhs: Float) -> float3 { return float3(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs) }

public func ==(lhs: float3, rhs: float3) -> Bool { return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z }

infix operator • { associativity left precedence 150 }
infix operator ⨯ { associativity left precedence 150 }
infix operator ⊗ { associativity left precedence 150 }

/// Dot product of two vectors
public func •(lhs: float3, rhs: float3) -> Float { return dot(lhs, rhs) }
/// Cross product of two vectors
public func ⨯(lhs: float3, rhs: float3) -> float3 { return cross(lhs, rhs) }
/// Inline product of two vectors
public func ⊗(lhs: float3, rhs: float3) -> float3 { return float3(x: lhs.x * rhs.x, y: lhs.y * rhs.y, z: lhs.z * rhs.z) }


public struct Ray {
	let o: float3
	let d: float3
	
	init(o: float3 = float3(), d: float3 = float3(x: 1, y: 0, z: 0)) {
		self.o = o
		self.d = d.unit
	}
	
	public func reflect(across: Ray, tolerance: Float = 0.0001) -> Ray {
		return Ray(o: across.o, d: -2 * (d • across.d) * across.d - d) * tolerance
	}
	
	public func refract(fromIndex: Float = 1.0, withNormal normal: Ray, toIndex: Float = 1.0, tolerance: Float = 0.0001) -> Ray {
		let direction = float3()
		let origin = normal.o + tolerance * direction
		return Ray(o: origin, d: direction)
	}
}

public func *(ray: Ray, dist: Float) -> Ray { return Ray(o: ray.o + dist * ray.d, d: ray.d) }
public func *(dist: Float, ray: Ray) -> Ray { return Ray(o: ray.o + dist * ray.d, d: ray.d) }

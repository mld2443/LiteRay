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
public func •(lhs: float3, rhs: float3) -> Float { return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z }
/// Cross product of two vectors
public func ⨯(lhs: float3, rhs: float3) -> float3 { return float3(x: lhs.y * rhs.z - lhs.z * rhs.y, y: lhs.z * rhs.x - lhs.x * rhs.z, z: lhs.x * rhs.y - lhs.y * rhs.x) }
/// Inline product of two vectors
public func ⊗(lhs: float3, rhs: float3) -> float3 { return float3(x: lhs.x * rhs.x, y: lhs.y * rhs.y, z: lhs.z * rhs.z) }


public struct Ray {
	var o = float3(), d = float3(x: 1, y: 0, z: 0)
}

public func *(ray: Ray, dist: Float) -> float3 { return ray.o + dist * ray.d }


public protocol Translatable {
	var position: float3 { get set }
}

public extension Translatable {
	public mutating func translate(x: Float, _ y: Float, _ z: Float) {
		position += float3(x: x, y: y, z: z)
	}
}

//
//  Quaternion.swift
//  LiteRay
//
//  Created by Matthew Dillard on 4/14/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation
import simd

public struct Quaternion {
	let wxyz: float4
	
	init(w: Float = 0.0, x: Float = 0.0, y: Float = 0.0, z: Float = 0.0) {
		wxyz = float4(w, x, y, z)
	}
	
	init(vector: float4) {
		wxyz = vector
	}
	
	init(data: Quaternion) {
		wxyz = data.wxyz
	}
	
	public var w: Float { return wxyz.w }
	public var x: Float { return wxyz.x }
	public var y: Float { return wxyz.y }
	public var z: Float { return wxyz.z }
	
	public var unit: Quaternion {
		return Quaternion(vector: normalize(wxyz))
	}
	
	public var matrix3x3: float3x3 {
		return float3x3([
			float3(1 - 2 * y * y - 2 * z * z,
				2 * x * y - 2 * w * z,
				2 * x * z + 2 * w * y),
			float3(2 * x * y + 2 * w * z,
				1 - 2 * x * x - 2 * z * z,
				2 * y * z - 2 * w * x),
			float3(2 * x * z - 2 * w * y,
				2 * y * z + 2 * w * x,
				1 - 2 * x * x - 2 * y * y)])
	}
}

public prefix func -(lhs: Quaternion) -> Quaternion {
	return Quaternion(w: lhs.wxyz.w, x: -lhs.wxyz.x, y: -lhs.wxyz.y, z: -lhs.wxyz.z)
}

public func +(lhs: Quaternion, rhs: Quaternion) -> Quaternion {
	return Quaternion(vector: lhs.wxyz + rhs.wxyz)
}

public func -(lhs: Quaternion, rhs: Quaternion) -> Quaternion {
	return Quaternion(vector: lhs.wxyz - rhs.wxyz)
}

public func *(lhs: Quaternion, rhs: Float) -> Quaternion {
	return Quaternion(vector: lhs.wxyz * rhs)
}

public func *(lhs: Float, rhs: Quaternion) -> Quaternion {
	return Quaternion(vector: lhs * rhs.wxyz)
}

public func *(lhs: Quaternion, rhs: Quaternion) -> Quaternion {
	return Quaternion(w: lhs.w * rhs.w - lhs.x * rhs.x - lhs.y * rhs.y - lhs.z * rhs.z,
	                  x: lhs.w * rhs.x + lhs.x * rhs.w + lhs.y * rhs.z - lhs.z * rhs.y,
	                  y: lhs.w * rhs.y + lhs.y * rhs.w + lhs.z * rhs.x - lhs.x * rhs.z,
	                  z: lhs.w * rhs.z + lhs.z * rhs.w + lhs.x * rhs.y - lhs.y * rhs.x)
}

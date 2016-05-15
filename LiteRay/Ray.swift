//
//  Ray.swift
//  LiteRay
//
//  Created by Matthew Dillard on 3/12/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation
import simd

public struct Ray {
	public let o: float3
	public let d: float3
	public let inv: float3
	
	public init(o: float3 = float3(), d: float3 = float3(x: 1, y: 0, z: 0)) {
		self.o = o
		self.d = d.unit
		self.inv = float3(1,1,1) / self.d
	}
	
	public func reflect(across: Ray, tolerance: Float = 0.000001) -> Ray {
		return Ray(o: across.o, d: simd.reflect(d, n: across.d).unit) * tolerance
	}
	
	public func refract(across: Ray, η: Float, tolerance: Float = 0.000001) -> Ray? {
		let refract = simd.refract(d, n: across.d, eta: η)
		
		if refract == float3(0,0,0) {
			return nil
		}
		
		return Ray(o: across.o, d: refract.unit) * tolerance
	}
	
	public func rotateAbout(point: float3, angle: Float) -> float3 {
		let a = o.x, b = o.y, c = o.z
		let u = d.x, v = d.y, w = d.z
		let x = point.x, y = point.y, z = point.z
		let L = d • d
		
		let cosθ = cosf(angle)
		let sinθ = sinf(angle)
		let sqrtL = sqrt(L)
		
		let rotX: Float = (a*(v*v + w*w) - u*(b*v + c*w - u*x - v*y - w*z))*(1 - cosθ) + L*x*cosθ + sqrtL*(-c*v + b*w - w*y + v*z)*sinθ
		let rotY: Float = (b*(u*u + w*w) - v*(a*u + c*w - u*x - v*y - w*z))*(1 - cosθ) + L*y*cosθ + sqrtL*(c*u - a*w + w*x - u*z)*sinθ
		let rotZ: Float = (c*(u*u + v*v) - w*(a*u + b*v - u*x - v*y - w*z))*(1 - cosθ) + L*z*cosθ + sqrtL*(-b*u + a*v - v*x + u*y)*sinθ
		
		return float3(rotX,rotY,rotZ)
	}
}

public func *(ray: Ray, dist: Float) -> Ray { return Ray(o: ray.o + dist * ray.d, d: ray.d) }
public func *(dist: Float, ray: Ray) -> Ray { return Ray(o: ray.o + dist * ray.d, d: ray.d) }

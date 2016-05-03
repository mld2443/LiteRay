//
//  Dielectric.swift
//  LiteRay
//
//  Created by Matthew Dillard on 5/2/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation
import simd

public struct Dielectric: Material {
	public var color: HDRColor
	public var refrIndex: Float
	
	public init(color: HDRColor = HDRColor(), opacity: Float = 0.0, refrIndex: Float = 1.0) {
		self.color = color
		self.refrIndex = refrIndex
	}
	
	public func scatter(incoming: Ray, intersect: Intersection, scene: Scene, inout color: HDRColor, inout bounce: Ray) -> Bool {
		var reflect_prob: Float = 1
		var cosine: Float = 1
		var eta: Float = 1
		var outward_normal = float3()
		
		let reflected = simd.reflect(incoming.d, n: intersect.norm)
		
		color = self.color
		
		if incoming.d • intersect.norm > 0 {
			outward_normal = -intersect.norm
			eta = refrIndex / scene.refrIndex
			cosine = refrIndex * (incoming.d • intersect.norm)
		} else {
			outward_normal = intersect.norm
			eta = scene.refrIndex / refrIndex
			cosine = -(incoming.d • intersect.norm)
		}
		
		let refracted = simd.refract(incoming.d, n: outward_normal, eta: eta)
		
		if refracted != float3(0,0,0) {
			reflect_prob = schlick(cosine, refrIndex)
		} else {
			bounce = Ray(o: intersect.point, d: reflected)
			reflect_prob = 1.0
		}
		
		if Float(drand48()) < reflect_prob {
			bounce = Ray(o: intersect.point, d: reflected)
		} else {
			bounce = Ray(o: intersect.point, d: refracted)
		}
		
		return true
	}
}

//
//  Metallic.swift
//  LiteRay
//
//  Created by Matthew Dillard on 5/2/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation
import simd

public struct Metallic: Material {
	public var color: HDRColor
	public var fuzz: Float
	
	public init(color: HDRColor = HDRColor.grayColor(), fuzz: Float = 0.0) {
		self.color = color
		self.fuzz = fuzz
	}
	
	public func scatter(incoming: Ray, intersect: Intersection, scene: Scene, inout color: HDRColor, inout bounce: Ray) -> Bool {
		let reflected = simd.reflect(incoming.d, n: intersect.norm)
		
		bounce = Ray(o: intersect.point, d: reflected + fuzz * randomInUnitSphere())
		color = self.color
		
		return (bounce.d • intersect.norm) > 0
	}
}

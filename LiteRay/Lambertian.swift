//
//  Lambertian.swift
//  LiteRay
//
//  Created by Matthew Dillard on 5/2/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation
import simd

public struct Lambertian: Material {
	public var color: HDRColor
	public var shininess: Float
	
	public init(color: HDRColor = HDRColor(), shininess: Float = 1.0) {
		self.color = color
		self.shininess = shininess
	}
	
	public func scatter(incoming: Ray, intersect: Intersection, scene: Scene, inout color: HDRColor, inout bounce: Ray) -> Bool {
		let target = intersect.point + intersect.norm + randomInUnitSphere()
		
		bounce = Ray(o: intersect.point, d: target - intersect.point)
		//		color = scene.phongShading(color, position: intersect.point, normal: intersect.norm, from: incoming.d, shininess: shininess)
		color = self.color
		
		return true
	}
}

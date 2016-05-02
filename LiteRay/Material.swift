//
//  Material.swift
//  LiteRay
//
//  Created by Matthew Dillard on 5/2/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation
import simd

public protocol Material {
	var color: HDRColor { get set }
	
	func scatter(incoming: Ray, intersect: Intersection, scene: Scene, inout color: HDRColor, inout bounce: Ray) -> Bool
}


func schlick(cosine: Float, _ index: Float) -> Float {
	var r0 = (1 - index) / (1 + index)
	r0 = r0 * r0
	return r0 + (1 - r0) * powf(1 - cosine, 5)
}

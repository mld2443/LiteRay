//
//  Light.swift
//  LiteRay
//
//  Created by Matthew Dillard on 3/12/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation
import simd

/// Light protocol
public protocol Light {
	var color: HDRColor { get set }
	
	func normalToLight(point: float3) -> float3
	
	func illuminated(point: float3) -> Bool
	
	func distance(point: float3) -> Float
}

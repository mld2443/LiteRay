//
//  SpotLight.swift
//  LiteRay
//
//  Created by Matthew Dillard on 3/12/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation
import simd

/// Spotlights emanate light from a source in a cone
public class SpotLight : Light, Translatable {
	public var color: HDRColor
	public var position: float3
	var direction: float3
	var angle: Float
	
	public init(color: HDRColor, position: float3, direction: float3, angle: Float) {
		self.color = color
		self.position = position
		self.direction = direction.unit
		self.angle = angle
	}
	
	public func normalToLight(point: float3) -> float3 { return (position - point).unit }
	
	public func illuminated(point: float3) -> Bool {
		let pointRay = (point - position).unit
		let angleBetween = acosf(direction • pointRay)  * (180.0 / Float(M_PI))
		return angleBetween <= angle
	}
	
	public func distance(point: float3) -> Float { return (position - point).length }
}

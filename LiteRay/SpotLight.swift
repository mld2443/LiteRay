//
//  SpotLight.swift
//  Trace
//
//  Created by Matthew Dillard on 3/12/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation
import simd

/// Spotlights emanate light from a source in a cone
public class SpotLight : Light, Translatable {
	public var color: HDRColor
	public var position: double3
	var direction: double3
	var angle: Double
	
	public init(color: HDRColor, position: double3, direction: double3, angle: Double) {
		self.color = color
		self.position = position
		self.direction = direction.unit
		self.angle = angle
	}
	
	public func normalToLight(point: double3) -> double3 { return (position - point).unit }
	
	public func illuminated(point: double3) -> Bool {
		let pointRay = (point - position).unit
		let angleBetween = acos(direction • pointRay)  * (180.0 / M_PI)
		return angleBetween <= angle
	}
	
	public func distance(point: double3) -> Double { return (position - point).length }
}

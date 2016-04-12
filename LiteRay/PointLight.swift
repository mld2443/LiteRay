//
//  PointLight.swift
//  LiteRay
//
//  Created by Matthew Dillard on 3/12/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation
import simd

/// Point light, all light emanates outward from one point
public class PointLight : Light, Translatable {
	public var color: HDRColor
	public var position: float3
	
	public init(color: HDRColor, position: float3) {
		self.color = color
		self.position = position
	}
	
	public func normalToLight(point: float3) -> float3 { return (position - point).unit }
	
	public func illuminated(_: float3) -> Bool { return true }
	
	public func distance(point: float3) -> Float { return (position - point).length }
}

//
//  DirectLight.swift
//  LiteRay
//
//  Created by Matthew Dillard on 3/12/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation
import simd
import Darwin

/// Direct lights act light infinitely far away pointlights
public class DirectLight : Light {
	public var color: HDRColor
	var direction: float3
	
	public init(color: HDRColor, direction: float3) {
		self.color = color
		self.direction = direction.unit
	}
	
	public func normalToLight(point: float3) -> float3 { return -direction }
	
	public func illuminated(_: float3) -> Bool { return true }
	
	public func distance(point: float3) -> Float { return FLT_MAX }
}

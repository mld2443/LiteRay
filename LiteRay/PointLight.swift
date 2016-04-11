//
//  PointLight.swift
//  Trace
//
//  Created by Matthew Dillard on 3/12/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation
import simd

/// Point light, all light emanates outward from one point
public class PointLight : Light, Translatable {
	public var color: HDRColor
	public var position: double3
	
	public init(color: HDRColor, position: double3) {
		self.color = color
		self.position = position
	}
	
	public func normalToLight(point: double3) -> double3 { return (position - point).unit }
	
	public func illuminated(_: double3) -> Bool { return true }
	
	public func distance(point: double3) -> Double { return (position - point).length }
}

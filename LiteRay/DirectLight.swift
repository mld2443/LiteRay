//
//  DirectLight.swift
//  Trace
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
	var direction: double3
	
	public init(color: HDRColor, direction: double3) {
		self.color = color
		self.direction = direction.unit
	}
	
	public func normalToLight(point: double3) -> double3 { return -direction }
	
	public func illuminated(_: double3) -> Bool { return true }
	
	public func distance(point: double3) -> Double { return DBL_MAX }
}

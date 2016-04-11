//
//  Light.swift
//  Trace
//
//  Created by Matthew Dillard on 3/12/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation
import simd

/// Light protocol
public protocol Light {
	var color: HDRColor { get set }
	
	func normalToLight(point: double3) -> double3
	
	func illuminated(point: double3) -> Bool
	
	func distance(point: double3) -> Double
}

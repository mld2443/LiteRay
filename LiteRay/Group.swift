//
//  Group.swift
//  LiteRay
//
//  Created by Matthew Dillard on 4/14/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Cocoa
import simd

public class Group: Shape {
	public var position: float3
	public var shapes: [Shape]
	
	public init(position: float3 = float3(), shapes: [Shape] = [Shape]()) {
		self.position = position
		self.shapes = shapes
	}
}

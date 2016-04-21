//
//  Scene.swift
//  LiteRay
//
//  Created by Matthew Dillard on 3/12/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Cocoa

public class Scene : NSObject, BooleanType {
	public var ambient: HDRColor
	public var refrIndex: Float
	public var lights = [Light]()
	public var shapes = [Shape]()
	
	public init(ambient: HDRColor = HDRColor.blackColor(), refrIndex: Float = 1.0) {
		self.ambient = ambient
		self.refrIndex = refrIndex
		super.init()
	}
	
	public func add(newLight: Light) { lights.append(newLight) }
	public func add(newShape: Shape) { shapes.append(newShape) }
	
	public var boolValue: Bool {
		return shapes.count > 0 && (ambient != HDRColor.blackColor() || lights.count > 0)
	}
	
	
}

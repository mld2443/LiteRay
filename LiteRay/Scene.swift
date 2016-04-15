//
//  Scene.swift
//  LiteRay
//
//  Created by Matthew Dillard on 3/12/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Cocoa

public class Scene : NSObject, BooleanType {
	var ambient = HDRColor.blackColor()
	var cameras = [Camera]()
	var lights = [Light]()
	var shapes = [Shape]()
	
	public init(ambient: HDRColor = HDRColor.blackColor()) {
		self.ambient = ambient
		super.init()
	}
	
	public func add(newLight: Light) { lights.append(newLight) }
	public func add(newShape: Shape) { shapes.append(newShape) }
	public func add(newCamera: Camera) { cameras.append(newCamera) }
	
	public var boolValue: Bool {
		return cameras.count != 0 && shapes.count > 0 && (ambient != HDRColor.blackColor() || lights.count > 0)
	}
	
	
}

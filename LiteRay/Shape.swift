//
//  Shape.swift
//  Trace
//
//  Created by Matthew Dillard on 3/12/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Cocoa
import simd

public protocol Shape : class, Translatable {
	var colors: ColorData { get set }
	var position: double3 { get set }
	
	func getNormal(at point: double3) -> double3
	
	func intersectRay(ray: Ray) -> Double
}

public extension Shape {
	public var ambient: HDRColor { return colors.ambient }
	public var diffuse: HDRColor { return colors.diffuse }
	public var offset: Double { return colors.offset }
	public var specular: HDRColor { return colors.specular }
	public var shininess: Double { return colors.shininess }
	public var glow: HDRColor { return colors.glow }
	public var opacity: Double { return colors.opacity }
}

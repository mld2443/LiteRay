//
//  Shape.swift
//  LiteRay
//
//  Created by Matthew Dillard on 3/12/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Cocoa
import simd

public protocol Shape : class, Translatable {
	var colors: ColorData { get set }
	var position: float3 { get set }
	var refrIndex: Float { get set }
	
	func getNormal(at point: float3) -> float3
	
	func intersectRay(ray: Ray) -> Float
}

public extension Shape {
	public var ambient: HDRColor { return colors.ambient }
	public var diffuse: HDRColor { return colors.diffuse }
	public var offset: Float { return colors.offset }
	public var specular: HDRColor { return colors.specular }
	public var shininess: Float { return colors.shininess }
	public var glow: HDRColor { return colors.glow }
	public var opacity: Float { return colors.opacity }
	public var reflectivity: Float { return colors.reflectivity }
}

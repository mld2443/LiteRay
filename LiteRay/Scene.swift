//
//  Scene.swift
//  LiteRay
//
//  Created by Matthew Dillard on 3/12/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Cocoa
import simd

public class Scene : NSObject {
	public var ambient: HDRColor
	public var shadingOffset: Float
	public var refrIndex: Float
	public var lights = [Light]()
	public var shapes = [Shape]()
	
	public init(ambient: HDRColor = HDRColor.blackColor(), shadingOffset: Float = 0.0, refrIndex: Float = 1.0) {
		self.ambient = ambient
		self.shadingOffset = shadingOffset
		self.refrIndex = refrIndex
		super.init()
	}
	
	public func add(newLight: Light) { lights.append(newLight) }
	public func add(newShape: Shape) { shapes.append(newShape) }
	
	public func castRay(ray: Ray, frustrum: (near: Float, far: Float)) -> Intersection? {
		var closest: Intersection?
		for shape in shapes {
			if let intersect = shape.intersectRay(ray, frustrum: (frustrum.near, closest?.dist ?? frustrum.far)) {
				closest = intersect
			}
		}
		return closest
	}
	
	public func phongShading(surface: HDRColor, position: float3, normal: float3, from: float3, shininess: Float, ambient: Bool = true, diffuse: Bool = true, specular: Bool = true) -> HDRColor {
		let ambientColor = (ambient ? surface * self.ambient : HDRColor())
		
		var diffuseColor = HDRColor()
		var specularColor = HDRColor()
		
		if diffuse || specular {
			for light in lights {
				let directionToLight = light.normalToLight(position)
				
				if light.illuminated(position) {
					let product = normal • directionToLight
					let offset = (product + shadingOffset)/(1 + shadingOffset)
					
					// color from direct diffuse illumination
					if diffuse {
						diffuseColor = diffuseColor + surface * light.color * max(offset, 0.0)
					}
					
					if product > 0.0 {
						let halfway = (from + directionToLight).unit
						let specularvalue = normal • halfway
						
						// color from specular highlights
						if specular {
							specularColor = specularColor + surface * light.color * pow(max(specularvalue, 0.0), shininess);
						}
					}
				}
			}
		}
		
		return ambientColor + diffuseColor + specularColor
	}
}

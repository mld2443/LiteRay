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
	
	public var directLights = [DirectLight]()
	public var pointLights = [PointLight]()
	public var spotLights = [SpotLight]()
	
	public var planes = [Plane]()
	public var quadrics = [Quadric]()
	
	public init(ambient: HDRColor = HDRColor.blackColor(), shadingOffset: Float = 0.0, refrIndex: Float = 1.0) {
		self.ambient = ambient
		self.shadingOffset = shadingOffset
		self.refrIndex = refrIndex
		super.init()
	}
	
	public func add(newLight: Light) {
		switch newLight {
		case is DirectLight:
			directLights.append(newLight as! DirectLight)
		case is PointLight:
			pointLights.append(newLight as! PointLight)
		case is SpotLight:
			spotLights.append(newLight as! SpotLight)
		default:
			break
		}
	}
	
	public func add(newShape: Shape) {
		switch newShape {
		case is Plane:
			planes.append(newShape as! Plane)
		case is Quadric:
			quadrics.append(newShape as! Quadric)
		default:
			break
		}
	}
	
	public func castRay(ray: Ray, frustrum: (near: Float, far: Float)) -> Intersection? {
		var closest: Intersection?
		for plane in planes {
			if let intersect = plane.intersectRay(ray, frustrum: (frustrum.near, closest?.dist ?? frustrum.far)) {
				closest = intersect
			}
		}
		for quadric in quadrics {
			if let intersect = quadric.intersectRay(ray, frustrum: (frustrum.near, closest?.dist ?? frustrum.far)) {
				closest = intersect
			}
		}
		return closest
	}
	
	public func phongShading(surface: HDRColor, position: float3, normal: float3, from: float3, ambient: Bool = false, diffuse: Bool = false, specular: Int = 0) -> HDRColor {
		let ambientColor = (ambient ? surface * self.ambient : HDRColor())
		
		var diffuseColor = HDRColor()
		var specularColor = HDRColor()
		
		if diffuse || specular > 0 {
			for directlight in directLights {
				let directionToLight = directlight.normalToLight(position)
				let product = normal • directionToLight
				
				// color from direct diffuse illumination
				if diffuse {
					let offset = (product + shadingOffset)/(1 + shadingOffset)
					
					diffuseColor = diffuseColor + surface * directlight.color * max(offset, 0.0)
				}
				
				if specular > 0 && product > 0.0 {
					let halfway = (from + directionToLight).unit
					let specularvalue = normal • halfway
					
					// color from specular highlights
					specularColor = specularColor + surface * directlight.color * pow(max(specularvalue, 0.0), Float(specular));
				}
			}
			
			for pointlight in pointLights {
				let directionToLight = pointlight.normalToLight(position)
				let product = normal • directionToLight
				
				// color from direct diffuse illumination
				if diffuse {
					let offset = (product + shadingOffset)/(1 + shadingOffset)
					
					diffuseColor = diffuseColor + surface * pointlight.color * max(offset, 0.0)
				}
				
				if specular > 0 && product > 0.0 {
					let halfway = (from + directionToLight).unit
					let specularvalue = normal • halfway
					
					// color from specular highlights
					specularColor = specularColor + surface * pointlight.color * pow(max(specularvalue, 0.0), Float(specular));
				}
			}
			
			for spotlight in spotLights {
				if spotlight.illuminated(position) {
					let directionToLight = spotlight.normalToLight(position)
					let product = normal • directionToLight
					
					// color from direct diffuse illumination
					if diffuse {
						let offset = (product + shadingOffset)/(1 + shadingOffset)
						
						diffuseColor = diffuseColor + surface * spotlight.color * max(offset, 0.0)
					}
					
					if specular > 0 && product > 0.0 {
						let halfway = (from + directionToLight).unit
						let specularvalue = normal • halfway
						
						// color from specular highlights
						specularColor = specularColor + surface * spotlight.color * pow(max(specularvalue, 0.0), Float(specular));
					}
				}
			}
		}
		
		return ambientColor + diffuseColor + specularColor
	}
}

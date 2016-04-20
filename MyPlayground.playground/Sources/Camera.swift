//
//  Camera.swift
//  LiteRay
//
//  Created by Matthew Dillard on 3/17/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Cocoa
import simd

public class Camera : NSObject {
	public var position: float3
	var frustrum: (near: Float, far: Float)
	var lookDirection: float3
	var upDirection: float3
	var FOV: Float
	var showNormal = false
	
	public init(position pos:float3 = float3(), lookDir:float3 = float3(x:0,y:0,z:1), FOV: Float = 90.0, nearClip near:Float = 1.0, farClip far:Float = 1000.0, upDir:float3 = float3(x:0,y:1,z:0)) {
		position = pos
		lookDirection = lookDir.unit
		self.FOV = FOV
		frustrum = (near, far)
		upDirection = upDir.unit
		super.init()
	}
	
	/// Preview the screen space, should disable
	/// AntiAliasing and a few other techniques.
	public func preview(scene: Scene, size: NSSize) -> NSImage {
		return capture(scene, size: size, AntiAliasing: 1)
	}
	
	/// Because of the way `imageFromRGB32Bitmap(pixels, size: size)`
	/// has to work, capture draws the image flipped along the Y-axis.
	public func capture(scene: Scene, size: NSSize, AntiAliasing: UInt) -> NSImage {
		// calculate the screen dimensions given the FOV
		let screenWidth = tanf((FOV / 2.0) * (Float(M_PI) / 180.0))
		let screenHeight = (Float(size.height) / Float(size.width)) * screenWidth
		
		// calculate the coordinate frame for screenspace
		let X₀ = (lookDirection ⨯ upDirection).unit
		let Y₀ = (lookDirection ⨯ X₀).unit
		
		// compute the average width of a pixel represented in screenspace
		let deltaX = (2.0 * screenWidth * X₀) / Float(size.width)
		let deltaY = (2.0 * screenHeight * Y₀) / Float(size.height)
		
		// grab the top left of the screenspace as the starting point for our image
		let upperLeft = position + lookDirection - (X₀ * screenWidth) - (Y₀ * screenHeight)
		
		// create the empty pixel array to convert to an NSImage
		var pixels = [HDRColor](count: Int(size.width * size.height), repeatedValue: HDRColor())
		
		// calculate the value of each pixel
		//let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
		
		for y in 0..<Int(size.height) {
			for x in 0..<Int(size.width) {
				let pixelPosition = upperLeft + Float(x) * deltaX + Float(y) * deltaY
				
				pixels[x + y * Int(size.width)] = self.getPixel(scene, SSPP: pixelPosition, AntiAliasing: AntiAliasing, dims: (deltaX, deltaY))
			}
		}
		
		return imageFromRGB32Bitmap(pixels, size: size)
	}
	
	/// Apply random sample AntiAliasing and begin the recursive raytracing process fro each sample
	private func getPixel(scene: Scene, SSPP: float3, AntiAliasing: UInt, dims: (width: float3, height: float3)) -> HDRColor {
		var pixel = HDRColor.blackColor()
		
		// collect samples of the scene for this current pixel
		for _ in 0...AntiAliasing {
			// randomly generate offsets for the current subsample
			let horiOffset = Float(drand48())
			let vertOffset = Float(drand48())
			
			// get the subsample position and construct a ray from it
			let subsample = SSPP + (dims.width * horiOffset) + (dims.height * vertOffset)
			let ray = Ray(o: position, d: (subsample - position).unit)
			
			pixel = pixel + trace(ray, scene: scene, step: 0, maxDepth: 5)
		}
		
		// return the normalized supersampled value
		return pixel / Float(AntiAliasing);
	}
	
	private func trace(ray: Ray, scene: Scene, step: UInt, maxDepth: UInt) -> HDRColor {
		var zValue = frustrum.far
		var closest: Intersection? = nil
		
		// detect the closest shape
		for s in scene.shapes {
			if let intersect = s.intersectRay(ray) {
				if (intersect.dist > frustrum.near && intersect.dist < zValue) {
					zValue = intersect.dist
					closest = intersect
				}
			}
		}
		
		// Stop in case we find no collision
		guard let intersect = closest else {
			return HDRColor.blackColor()
		}
		
		if showNormal {
			let color = 0.5 * HDRColor(r: intersect.norm.x + 1.0, g: intersect.norm.y + 1.0, b: intersect.norm.z + 1.0)
			
			return color
		}
		
		var refractColor = HDRColor()
		var reflectColor = HDRColor()
		var opaqueColor = HDRColor()
		
		// retrieve the shape's colors
		if step < maxDepth  && intersect.material.opacity < 1.0 {
			refractColor = (1.0 - intersect.material.opacity) * getRefractedColor(scene, at: intersect, from: ray, step: step, maxDepth: maxDepth)
		}
		
		if intersect.material.reflectivity > 0.0 {
			reflectColor = intersect.material.reflectivity * getReflectedColor(scene, at: intersect, from: ray, step: step, maxDepth: maxDepth)
		}
		
		if intersect.material.opacity > 0.0 && intersect.material.reflectivity < 1.0 {
			opaqueColor = getOpaqueColor(scene, at: intersect, from: -ray.d)
		}
		
		return opaqueColor + refractColor + reflectColor
	}
	
	private func getOpaqueColor(scene: Scene, at intersect: Intersection, from: float3) -> HDRColor {
		// color independant of all other lighting conditions
		let glow = intersect.material.glow
		
		// color dependant on the ambient light of the scene
		let ambient = scene.ambient * intersect.material.ambient;
		
		var diffuse = HDRColor(), specular = HDRColor()
		// iterate through all lights in the scene
		for l  in scene.lights {
			let directionToLight = l.normalToLight(intersect.point)
			
			// shadow check
			if l.illuminated(intersect.point) && !obstructed(Ray(o: intersect.point, d: directionToLight), inScene: scene, from: l) {
				let product = intersect.norm • directionToLight
				let offset = (product + intersect.material.offset)/(1 + intersect.material.offset)
				
				// color from direct diffuse illumination
				diffuse = diffuse + intersect.material.diffuse * l.color * max(offset, 0.0)
				
				if product > 0.0 {
					let halfway = (from + directionToLight).unit
					let specularvalue = intersect.norm • halfway
					
					// color from specular highlights
					specular = specular + intersect.material.specular * l.color * pow(max(specularvalue, 0.0), intersect.material.shininess);
				}
			}
		}
		
		return glow + ambient + diffuse + specular
	}
	
	private func getReflectedColor(scene:Scene, at intersect: Intersection, from: Ray, step: UInt, maxDepth: UInt) -> HDRColor {
		let normalRay = Ray(o: intersect.point, d: intersect.norm)
		
		return trace(from.reflect(normalRay), scene: scene, step: step + 1, maxDepth: maxDepth)
	}
	
	private func getRefractedColor(scene:Scene, at intersect: Intersection, from: Ray, step: UInt, maxDepth: UInt) -> HDRColor {
		let normalRay = Ray(o: intersect.point, d: intersect.norm)
		
		var eta: Float
		
		if intersect.norm • from.d > 0.0{
			eta = intersect.material.refrIndex / scene.refrIndex
		} else {
			eta = scene.refrIndex / intersect.material.refrIndex
		}
		
		return trace(from.refract(normalRay, η: eta), scene: scene, step: step + 1, maxDepth: maxDepth)
	}
	
	private func obstructed(inRay: Ray, inScene: Scene, from: Light, tolerance: Float = 0.0001) -> Bool {
		// small tolerance to avoid hitting the surface we want to check for shadows
		let ray = inRay * tolerance
		
		// first get the distance from the surface to the light
		let distanceToLight = from.distance(ray.o);
		
		// then see if any shapes are closer than that
		for s in inScene.shapes {
			if let intersect = s.intersectRay(ray) {
				if intersect.dist > 0.0 && intersect.dist < distanceToLight {
					return true;
				}
			}
		}
		
		return false
	}
}

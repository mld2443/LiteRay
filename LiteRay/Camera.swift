//
//  Camera.swift
//  LiteRay
//
//  Created by Matthew Dillard on 3/17/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Cocoa
import simd

public class Camera : NSObject, Translatable {
	public var position: float3
	var frustrum: (near: Float, far: Float)
	var lookDirection: float3
	var upDirection: float3
	var FOV: Float
	
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
		let uWidth = tanf((FOV / 2.0) * (Float(M_PI) / 180.0))
		let vHeight = (Float(size.height) / Float(size.width)) * uWidth
		
		// calculate the coordinate frame for screenspace
		let X₀ = (lookDirection ⨯ upDirection).unit
		let Y₀ = (X₀ ⨯ lookDirection).unit
		
		// compute the average width of a pixel represented in screenspace
		let deltaX = (2 * uWidth * X₀) / Float(size.width)
		let deltaY = (2 * vHeight * Y₀) / Float(size.height)
		
		// grab the top left of the screenspace as the starting point for our image
		var currentLeft = position + lookDirection - (X₀ * uWidth) + (Y₀ * vHeight)
		
		// create the empty pixel array to convert to an NSImage
		var pixels = [HDRColor]()
		
		// calculate the value of each pixel
		for _ in 0..<UInt(size.height) {
			var pixelPosition = currentLeft
			for _ in 0..<UInt(size.width) {
				pixels.append(getPixel(scene, SSPP: pixelPosition, AntiAliasing: AntiAliasing, dims: (deltaX, deltaY)))
				
				pixelPosition += deltaX
			}
			currentLeft -= deltaY;
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
	
	private func trace(ray: Ray, scene: Scene, step: UInt, maxDepth: UInt, ignore: Shape? = nil) -> HDRColor {
		var zValue = frustrum.far
		var closest: Shape? = nil
		
		// detect the closest shape
		for s in scene.shapes where Optional<Shape>(s) !== ignore {
			let intersect = s.intersectRay(ray)
			if (intersect > frustrum.near && intersect < zValue) {
				zValue = intersect
				closest = s
			}
		}
		
		// Stop in case we find no collision
		guard let shape = closest else {
			return HDRColor.blackColor()
		}
		
		let point = (ray * zValue).o
		
		// retrieve the shape's colors
		if step < maxDepth  && shape.reflectivity > 0.0 {
			let opaqueColor = (shape.opacity - shape.reflectivity) * getOpaqueColor(scene, of: shape, at: point, from: -ray.d)
			let reflectColor = shape.reflectivity * getReflectedColor(scene, of: shape, at: point, from: ray, step: step, maxDepth: maxDepth)
			
			return opaqueColor + reflectColor
		}
		else {
			let opaqueColor = getOpaqueColor(scene, of: shape, at: point, from: -ray.d)
			
			return opaqueColor
		}
	}
	
	private func getOpaqueColor(scene: Scene, of shape: Shape, at point: float3, from: float3) -> HDRColor {
		// color independant of all other lighting conditions
		let glow = shape.glow
		
		// color dependant on the ambient light of the scene
		let ambient = scene.ambient * shape.ambient;
		
		var diffuse = HDRColor(), specular = HDRColor()
		// iterate through all lights in the scene
		for l  in scene.lights {
			let surfaceNormal = shape.getNormal(at: point)
			let directionToLight = l.normalToLight(point)
			
			// shadow check
			if l.illuminated(point) && !obstructed(Ray(o: point, d: directionToLight), on: shape, inScene: scene, from: l) {
				let product = surfaceNormal • directionToLight
				let offset = (product + shape.offset)/(1 + shape.offset)
				
				// color from direct diffuse illumination
				diffuse = diffuse + shape.diffuse * l.color * max(offset, 0.0)
				
				if product > 0.0 {
					let halfway = (from + directionToLight).unit
					let specularvalue = surfaceNormal • halfway
					
					// color from specular highlights
					specular = specular + shape.specular * l.color * pow(max(specularvalue, 0.0), shape.shininess);
				}
			}
		}
		
		return glow + ambient + diffuse + specular
	}
	
	private func getReflectedColor(scene:Scene, of ignore: Shape, at point: float3, from: Ray, step: UInt, maxDepth: UInt) -> HDRColor {
		let normalRay = Ray(o: point, d: ignore.getNormal(at: point))
		
		return trace(from.reflect(normalRay), scene: scene, step: step + 1, maxDepth: maxDepth)
	}
	
	private func obstructed(ray: Ray, on: Shape, inScene: Scene, from: Light) -> Bool {
		// first get the distance from the surface to the light
		let distanceToLight = from.distance(ray.o);
		
		// then see if any shapes are closer than that
		for s in inScene.shapes where s !== on {
			let intersect = s.intersectRay(ray)
			if intersect > 0.0 && intersect < distanceToLight {
				return true;
			}
		}
		
		return false
	}
}

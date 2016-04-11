//
//  Camera.swift
//  Trace
//
//  Created by Matthew Dillard on 3/17/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Cocoa
import simd

public class Camera : NSObject, Translatable {
	public var position: double3
	var frustrum: (near: Double, far: Double)
	var lookDirection: double3
	var upDirection: double3
	var FOV: Double
	
	public init(position pos:double3 = double3(), lookDir:double3 = double3(x:1,y:0,z:0), FOV: Double = 90.0, nearClip near:Double = 1.0, farClip far:Double = 1000.0, upDir:double3 = double3(x:0,y:1,z:0)) {
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
		let uWidth = tan((FOV / 2.0) * (M_PI / 180.0))
		let vHeight = (Double(size.height) / Double(size.width)) * uWidth
		
		// calculate the coordinate frame for screenspace
		let X₀ = (lookDirection ⨯ upDirection).unit
		let Y₀ = (X₀ ⨯ lookDirection).unit
		
		// compute the average width of a pixel represented in screenspace
		let deltaX = (2 * uWidth * X₀) / Double(size.width)
		let deltaY = (2 * vHeight * Y₀) / Double(size.height)
		
		// grab the top left of the screenspace as the starting point for our image
		var currentLeft = position + lookDirection - (X₀ * uWidth) + (Y₀ * vHeight)
		
		// create the empty pixel array to convert to an NSImage
		var pixels = [HDRColor]()
		
		// calculate the value of each pixel
		for _ in 0..<Int(size.height) {
			var pixelPosition = currentLeft
			for _ in 0..<Int(size.width) {
				pixels.append(getPixel(scene, SSPP: pixelPosition, AntiAliasing: AntiAliasing, dims: (deltaX, deltaY)))
				
				pixelPosition += deltaX
			}
			currentLeft -= deltaY;
		}
		
		return imageFromRGB32Bitmap(pixels, size: size)
	}
	
	private func getPixel(scene: Scene, SSPP: double3, AntiAliasing: UInt, dims: (width: double3, height: double3)) -> HDRColor {
		var pixel = HDRColor()
		
		// collect samples of the scene for this current pixel
		for _ in 0...AntiAliasing {
			// randomly generate offsets for the current subsample
			let horiOffset = drand48()
			let vertOffset = drand48()
			
			// get the subsample position and construct a ray from it
			let subsample = SSPP + (dims.width * horiOffset) + (dims.height * vertOffset)
			let ray = Ray(o: position, d: (subsample - position).unit)
			
			pixel += trace(ray, scene: scene, step: 0, maxDepth: 5)
		}
		
		// return the normalized supersampled value
		return pixel / Double(AntiAliasing);
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
		guard closest != nil else {
			return HDRColor.blackColor()
		}
		
		// retrieve the shape's colors
		return getColor(scene, of: closest!, at: ray * zValue, from: -ray.d)
	}
	
	private func getColor(scene: Scene, of shape: Shape, at point: double3, from: double3) -> HDRColor {
		// color independant of all other lighting conditions
		let glow = shape.glow
		
		// color dependant on the ambient light of the scene
		let ambient = scene.ambient * shape.ambient;
		
		var diffuse = HDRColor(), specular = HDRColor()
		// iterate through all lights in the scene
		for l  in scene.lights {
			let directionToLight = l.normalToLight(point)
			
			// shadow check
			if l.illuminated(point) && !obstructed(Ray(o: point, d: directionToLight), on: shape, inScene: scene, from: l) {
				let shapeNormal = shape.getNormal(at: point)
				let product = shapeNormal • directionToLight
				let offset = (product + shape.offset)/(1 + shape.offset)
				
				// color from direct diffuse illumination
				diffuse += shape.diffuse * l.color * max(offset, 0.0)
				
				if product > 0.0 {
					let halfway = (from + l.normalToLight(point)).unit
					let specularvalue = shape.getNormal(at: point) • halfway
					
					// color from specular highlights
					specular += shape.specular * l.color * pow(max(specularvalue, 0.0), shape.shininess);
				}
			}
		}
		
		return glow + ambient + diffuse + specular
	}
	
	private func obstructed(ray: Ray, on: Shape, inScene: Scene, from: Light) -> Bool {
		// first get the distance from the surface to the light
		let distanceToLight = from.distance(ray.o);
		
		// then see if any shapes are closer than that
		for s in inScene.shapes {
			// we can ignore the original object
			if s !== on {
				let intersect = s.intersectRay(ray)
				if intersect > 0.0 && intersect < distanceToLight {
					return true;
				}
			}
		}
		
		return false
	}
}

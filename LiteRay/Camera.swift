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
	var frustrum: ClosedInterval<Float>
	var lookDirection: float3
	var upDirection: float3
	var FOV: Float
	var showNormal = false
	
	public init(position pos:float3 = float3(), lookDir:float3 = float3(x:0,y:0,z:1), FOV: Float = 90.0, frustrum: ClosedInterval<Float> = 0.001...Float.infinity, upDir:float3 = float3(x:0,y:1,z:0)) {
		self.position = pos
		self.lookDirection = lookDir.unit
		self.FOV = FOV
		self.frustrum = frustrum
		self.upDirection = upDir.unit
		super.init()
	}
	
	/// Because of the way `imageFromRGB32Bitmap(pixels, size: size)`
	/// has to work, capture draws the image flipped along the Y-axis.
	public func capture(scene: Scene, size: NSSize, AntiAliasing: UInt, depth: UInt = 5) -> NSImage {
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
				
				pixels[x + y * Int(size.width)] = self.getPixel(scene, SSPP: pixelPosition, AntiAliasing: AntiAliasing, dims: (deltaX, deltaY), depth: depth)
			}
		}
		
		return imageFromRGB32Bitmap(pixels, size: size)
	}
	
	/// Apply random sample AntiAliasing and begin the recursive raytracing process fro each sample
	private func getPixel(scene: Scene, SSPP: float3, AntiAliasing: UInt, dims: (width: float3, height: float3), depth: UInt) -> HDRColor {
		var pixel = HDRColor.blackColor()
		
		// collect samples of the scene for this current pixel
		for _ in 0...AntiAliasing {
			// randomly generate offsets for the current subsample
			let horiOffset = Float(drand48())
			let vertOffset = Float(drand48())
			
			// get the subsample position and construct a ray from it
			let subsample = SSPP + (dims.width * horiOffset) + (dims.height * vertOffset)
			let ray = Ray(o: position, d: (subsample - position).unit)
			
			pixel = pixel + trace(ray, scene: scene, step: 0, maxDepth: depth)
		}
		
		// Color correction
		pixel = pixel / Float(AntiAliasing)
		pixel = HDRColor(r: sqrt(pixel.r), g: sqrt(pixel.g), b: sqrt(pixel.b))
		
		// return the normalized supersampled value
		return pixel
	}
	
	private func trace(ray: Ray, scene: Scene, step: UInt, maxDepth: UInt) -> HDRColor {
		if let intersect = scene.castRay(ray, frustrum: frustrum) {
			var bounce = ray
			var color = HDRColor()
			
			if step < maxDepth && intersect.material.scatter(ray, intersect: intersect, scene: scene, color: &color, bounce: &bounce) {
				return color * trace(bounce, scene: scene, step: step + 1, maxDepth: maxDepth)
			} else {
				return HDRColor(r: 0, g: 0, b: 0)
			}
		}
		
		let t = 0.5 * ray.d.y + 1
		return (1 - t) * HDRColor(r: 1.0, g: 1.0, b: 1.0) + t * HDRColor(r: 0.5, g: 0.7, b: 1.0)
	}
}

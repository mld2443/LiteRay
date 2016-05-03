//
//  MetalViewController.swift
//  LiteRay
//
//  Created by Matthew Dillard on 5/2/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Cocoa

class MetalViewController : NSViewController {
	var metalDevice: MTLDevice!
	var metalCommandQueue: MTLCommandQueue!
	var metalDefaultLibrary: MTLLibrary!
	var metalCommandBuffer: MTLCommandBuffer!
	var metalComputeCommandEncoder: MTLComputeCommandEncoder!
	
	var directLightBuffer: MTLBuffer!
	var pointLightBuffer: MTLBuffer!
	var spotLightBuffer: MTLBuffer!
	
	func setupMetal() {
		// Get access to iPhone or iPad GPU
		metalDevice = MTLCreateSystemDefaultDevice()
		
		// Queue to handle an ordered list of command buffers
		metalCommandQueue = metalDevice.newCommandQueue()
		
		// Access to Metal functions that are stored in Shaders.metal file, e.g. sigmoid()
		metalDefaultLibrary = metalDevice.newDefaultLibrary()
		
		// Buffer for storing encoded commands that are sent to GPU
		metalCommandBuffer = metalCommandQueue.commandBuffer()
	}
	
	func setupShaderInMetalPipeline(shaderName:String) -> (shader:MTLFunction!, computePipelineState:MTLComputePipelineState!)  {
		let shader = metalDefaultLibrary.newFunctionWithName(shaderName)
		let computePipeLineDescriptor = MTLComputePipelineDescriptor()
		
		computePipeLineDescriptor.computeFunction = shader
		
		var computePipelineState:MTLComputePipelineState? = nil
		do {
			
			//                computePipelineState = try metalDevice.newComputePipelineStateWithDescriptor(computePipeLineDescriptor)
			computePipelineState = try metalDevice.newComputePipelineStateWithFunction(shader!)
		} catch {
			print("catching..")
			exit(1)
		}
		return (shader, computePipelineState)
	}
	
	func setMetalLightBuffers(scene: Scene) {
	}
	
	func createMetalFrameBuffer(inout frameBuffer: [HDRColor]) -> MTLBuffer {
		let byteLength = frameBuffer.count * sizeof(HDRColor)
		return metalDevice.newBufferWithBytes(&frameBuffer, length: byteLength, options: MTLResourceOptions.CPUCacheModeDefaultCache)
	}
}

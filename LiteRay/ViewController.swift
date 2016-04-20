//
//  ViewController.swift
//  LiteRay
//
//  Created by Matthew Dillard on 4/6/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Cocoa
import simd

class ViewController: NSViewController {
	var scene = Scene()
	var camera = Camera()
	
	@IBOutlet weak var ImageView: NSImageView!
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		loadReflectiveScene()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		ImageView.image = camera.capture(scene, size: ImageView.bounds.size, AntiAliasing: 1)
	}
	
	private func loadReflectiveScene() {
		scene.ambient = HDRColor(r: 0.05,g: 0.05,b: 0.05)
		camera = Camera(position: float3(0,8,-10), lookDir: float3(0,0,1), FOV: 110.0, nearClip: 0.1, farClip: 1000.0)
		
		scene.add(SpotLight(color: HDRColor(r: 0.8, g: 0.8, b: 0.8), position: float3(0,23.99,0), direction: float3(0,-1,0), angle: 40.0))
		
		let white = ColorData(ambient: HDRColor(r: 0.05,g: 0.1,b: 0.12), diffuse: HDRColor(r: 0.5,g: 0.5,b: 0.5), specular: HDRColor(r: 0.5,g: 0.5,b: 0.5), shininess: 3.0)
		let red = ColorData(ambient: HDRColor(r: 0.1,g: 0.05,b: 0.02), diffuse: HDRColor(r: 0.5,g: 0.2,b: 0.1), specular: HDRColor(r: 0.5,g: 0.2,b: 0.1), shininess: 20.0)
		let green = ColorData(ambient: HDRColor(r: 0.0,g: 0.1,b: 0.0), diffuse: HDRColor(r: 0.0,g: 0.5,b: 0.0), offset: 0.5, specular: HDRColor(r: 0.0,g: 0.5,b: 0.0), shininess: 20.0)
		
		let mirror = ColorData(reflectivity: 1.0)
		
		// spheres
		scene.add(Sphere(colors: white, position: float3(-6,4,2), radius: 4)!) // right
		scene.add(Sphere(colors: mirror, position: float3(6,3,8), radius: 3)!) // left
		scene.add(Sphere(colors: mirror, position: float3(0,1,10), radius: 1)!) // center
		
		// walls
		scene.add(Plane(colors: white, position: float3(0,24,0), normal: float3(0,-1,0))) // ceiling
		scene.add(Plane(colors: red, position: float3(12,0,0), normal: float3(-1,0,0))) // front
		scene.add(Plane(colors: white, position: float3(0,0,12), normal: float3(0,0,-1))) // right
		scene.add(Plane(colors: green, position: float3(-12,0,0), normal: float3(1,0,0))) // back
		scene.add(Plane(colors: white, position: float3(0,0,-12), normal: float3(0,0,1))) // left
		scene.add(Plane(colors: white, position: float3(0,0,0), normal: float3(0,1,0))) // floor
	}
	
	override var representedObject: AnyObject? {
		didSet {
		// Update the view, if already loaded.
		}
	}
}


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
	
	
	@IBOutlet weak var ImageView: NSImageView!
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		scene.add(Camera())
		
//		loadSimpleScene()
//		loadReflectiveScene()
//		loadExampleScene()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		ImageView.image = scene.cameras[0].preview(scene, size: ImageView.bounds.size)
	}
	
	private func loadSimpleScene() {
		scene.ambient = HDRColor(r: 0.05,g: 0.05,b: 0.05)
		scene.add(Camera(position: float3(x: 0, y: 0, z: 0), lookDir: float3(x: 1, y: 0, z: 0), FOV: 90.0, nearClip: 0.2, farClip: 1000.0))
		
		scene.add(DirectLight(color: HDRColor.whiteColor(), direction: float3(x: 1, y: 1, z: 1)))
		
		let teal = ColorData(ambient: HDRColor(r: 0.05,g: 0.1,b: 0.12), diffuse: HDRColor(r: 0.2,g: 0.5,b: 0.6), specular: HDRColor(r: 0.2,g: 0.5,b: 0.6), shininess: 100.0)
		let yellow = ColorData(ambient: HDRColor(r: 0.5,g: 0.5,b: 0.0), diffuse: HDRColor(r: 1.0,g: 1.0,b: 0.0), specular: HDRColor(r: 1.0,g: 1.0,b: 0.0), shininess: 5.0)
		
		scene.add(Sphere(colors: teal, position: float3(x: 10, y: 0, z: 0), radius: 3)!)
		scene.add(Plane(colors: yellow, position: float3(x: 20,y: 0,z: 0), normal: float3(x: -1,y: 0,z: 0)))
	}
	
	private func loadReflectiveScene() {
		scene.ambient = HDRColor(r: 0.05,g: 0.05,b: 0.05)
		scene.add(Camera(position: float3(0,8,-10), lookDir: float3(0,0,1), FOV: 110.0, nearClip: 0.1, farClip: 1000.0))
		
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
	
	private func loadExampleScene() {
		scene.ambient = HDRColor(r: 0.05,g: 0.05,b: 0.05)
		scene.add(Camera(position: float3(x: 30, y: 10, z: -8), lookDir: float3(x: -60, y: -10, z: 8), FOV: 70.0, nearClip: 0.2, farClip: 10000.0))
		
		scene.add(SpotLight(color: HDRColor(r: 0.1,g: 0.1,b: 0.7), position: float3(x: 40,y: 25,z: 10),  direction: float3(x: -60,y: -12,z: 6), angle: 20.5))
		scene.add(PointLight(color: HDRColor(r: 0.1,g: 0.4,b: 0.1), position: float3(x: 70,y: -40,z: 10)))
		scene.add(DirectLight(color: HDRColor(r: 0.4,g: 0.1,b: 0.1), direction: float3(x: -20,y: 10,z: 50)))
		
		let yellow = ColorData(ambient: HDRColor(r: 0.5,g: 0.5,b: 0.1), diffuse: HDRColor(r: 1.0,g: 1.0,b: 0.0), offset: 0.5, specular: HDRColor(r: 1.0,g: 1.0,b: 0.0), shininess: 5.0)
		let purple = ColorData(ambient: HDRColor(r: 0.04,g: 0.0,b: 0.06), diffuse: HDRColor(r: 0.2,g: 0.0,b: 0.3), offset: 0.5, specular: HDRColor(r: 0.6,g: 0.3,b: 0.8), shininess: 100.0)
		let grey = ColorData(ambient: HDRColor(r: 0.3,g: 0.3,b: 0.4), diffuse: HDRColor(r: 0.9,g: 0.9,b: 1.0), offset: 0.5, specular: HDRColor(r: 0.9,g: 0.9,b: 1.0), shininess: 30.0, glow: HDRColor(r: 0.1,g: 0.1,b: 0.1))
		let darkRed = ColorData(ambient: HDRColor(r: 0.1,g: 0.05,b: 0.02), diffuse: HDRColor(r: 0.5,g: 0.2,b: 0.1), offset: 0.5, specular: HDRColor(r: 0.5,g: 0.2,b: 0.1), shininess: 20.0)
		let teal = ColorData(ambient: HDRColor(r: 0.05,g: 0.1,b: 0.12), diffuse: HDRColor(r: 0.2,g: 0.5,b: 0.6), offset: 0.5, specular: HDRColor(r: 0.2,g: 0.5,b: 0.6), shininess: 100.0)
		let forestGreen = ColorData(ambient: HDRColor(r: 0.0,g: 0.1,b: 0.0), diffuse: HDRColor(r: 0.0,g: 0.5,b: 0.0), offset: 0.5, specular: HDRColor(r: 0.0,g: 0.5,b: 0.0), shininess: 20.0)
		let limeGreen = ColorData(ambient: HDRColor(r: 0.08,g: 0.16,b: 0.0), diffuse: HDRColor(r: 0.4,g: 0.8,b: 0.0), offset: 0.5, specular: HDRColor(r: 0.4,g: 0.8,b: 0.0), shininess: 20.0)
		let matteBlue = ColorData(ambient: HDRColor(r: 0.04,g: 0.02,b: 0.14), diffuse: HDRColor(r: 0.2,g: 0.1,b: 0.7), offset: 0.5, specular: HDRColor(r: 0.2,g: 0.1,b: 0.7), shininess: 15.0)
		let orange = ColorData(ambient: HDRColor(r: 0.18,g: 0.08,b: 0.0), diffuse: HDRColor(r: 0.9,g: 0.4,b: 0.0), offset: 0.5, specular: HDRColor(r: 0.9,g: 0.4,b: 0.0), shininess: 20.0)
		let babyBlue = ColorData(ambient: HDRColor(r: 0.16,g: 0.16,b: 0.16), diffuse: HDRColor(r: 0.5,g: 0.8,b: 0.8), offset: 0.5, specular: HDRColor(r: 0.5,g: 0.8,b: 0.8), shininess: 100.0)
		let pearl = ColorData(ambient: HDRColor(r: 0.16,g: 0.16,b: 0.16), diffuse: HDRColor(r: 0.8,g: 0.8,b: 0.5), offset: 0.5, specular: HDRColor(r: 0.8,g: 0.8,b: 0.5), shininess: 100.0)
		
		scene.add(Quadric(colors: purple, position: float3(x: -20,y: 0,z: 35), equation: Equation(A: 5, B: -1, C: 5, J: -6)))
		
		scene.add(Plane(colors: yellow, position: float3(x: -60,y: 0,z: 0), normal: float3(x: 1,y: 0,z: 0)))
		
		scene.add(Cylinder(colors: purple, position: float3(x: -30,y: 0,z: 0), xz_radius: 5.0)!)
		
		scene.add(Sphere(colors: grey, position: float3(x: -30.0,y: 0.0,z: 0.0), radius: 11.0)!)
		scene.add(Sphere(colors: darkRed, position: float3(x: -30.0,y: 7.0,z: 0.0), radius: 10.0)!)
		scene.add(Sphere(colors: teal, position: float3(x: -30.0,y: -7.0,z: 0.0), radius: 10.0)!)
		scene.add(Sphere(colors: forestGreen, position: float3(x: -30.0,y: 3.0,z: 5.0), radius: 10.0)!)
		scene.add(Sphere(colors: limeGreen, position: float3(x: -30.0,y: -3.0,z: 5.0), radius: 10.0)!)
		scene.add(Sphere(colors: matteBlue, position: float3(x: -30.0,y: -3.0,z: -5.0), radius: 10.0)!)
		scene.add(Sphere(colors: orange, position: float3(x: -30.0,y: 3.0,z: -5.0), radius: 10.0)!)
		
		scene.add(Sphere(colors: babyBlue, position: float3(x: -40.0,y: 20.0,z: -30.0), radius: 10.0)!)
		scene.add(Sphere(colors: pearl, position: float3(x: -40.0,y: -20.0,z: 30.0), radius: 10.0)!)
	}

	override var representedObject: AnyObject? {
		didSet {
		// Update the view, if already loaded.
		}
	}
}


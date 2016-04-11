//
//  MasterViewController.swift
//  Trace
//
//  Created by Matthew Dillard on 4/6/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Cocoa
import simd

class ViewController: NSViewController {
	var scene = Scene(ambient: HDRColor.grayColor())
	var camera = Camera()
	
	@IBOutlet weak var ImageView: NSImageView!
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		loadSimpleScene()
		//loadExampleScene()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		ImageView.image = camera.preview(scene, size: ImageView.bounds.size)
	}
	
	private func loadSimpleScene() {
		scene.ambient = HDRColor(r: 0.05,g: 0.05,b: 0.05)
		
		scene.addLight(DirectLight(color: HDRColor.whiteColor(), direction: double3(x: 1, y: 1, z: 1)))
		
		let teal = ColorData(ambient: HDRColor(r: 0.05,g: 0.1,b: 0.12), diffuse: HDRColor(r: 0.2,g: 0.5,b: 0.6), offset: 0.5, specular: HDRColor(r: 0.2,g: 0.5,b: 0.6), shininess: 100.0, glow: HDRColor(), opacity: 1.0)
		let yellow = ColorData(ambient: HDRColor(r: 0.5,g: 0.5,b: 0.1), diffuse: HDRColor(r: 1.0,g: 1.0,b: 0.0), offset: 0.5, specular: HDRColor(r: 1.0,g: 1.0,b: 0.0), shininess: 5.0, glow: HDRColor(), opacity: 1.0)
		
		scene.addShape(Sphere(colors: yellow, position: double3(x: 10, y: 0, z: 3), radius: 3)!)
		scene.addShape(Sphere(colors: teal, position: double3(x: 10, y: 0, z: 0), radius: 3)!)
		scene.addShape(Plane(colors: yellow, position: double3(x: 20,y: 0,z: 0), normal: double3(x: -1,y: 0,z: 0)))
	}
	
	private func loadExampleScene() {
		scene.ambient = HDRColor(r: 0.05,g: 0.05,b: 0.05)
		camera = Camera(position: double3(x: 30, y: 10, z: -8), lookDir: double3(x: -60, y: -10, z: 8), FOV: 70.0, nearClip: 0.2, farClip: 10000.0)
		
		scene.addLight(SpotLight(color: HDRColor(r: 0.1,g: 0.4,b: 0.1), position: double3(x: 40,y: 25,z: 10),  direction: double3(x: -60,y: -12,z: 6), angle: 20.5))
		scene.addLight(PointLight(color: HDRColor(r: 0.1,g: 0.4,b: 0.1), position: double3(x: 70,y: -40,z: 10)))
		scene.addLight(DirectLight(color: HDRColor(r: 0.4,g: 0.1,b: 0.1), direction: double3(x: -20,y: 10,z: 50)))
		
		let yellow = ColorData(ambient: HDRColor(r: 0.5,g: 0.5,b: 0.1), diffuse: HDRColor(r: 1.0,g: 1.0,b: 0.0), offset: 0.5, specular: HDRColor(r: 1.0,g: 1.0,b: 0.0), shininess: 5.0, glow: HDRColor(), opacity: 1.0)
		let purple = ColorData(ambient: HDRColor(r: 0.04,g: 0.0,b: 0.06), diffuse: HDRColor(r: 0.2,g: 0.0,b: 0.3), offset: 0.5, specular: HDRColor(r: 0.6,g: 0.3,b: 0.8), shininess: 100.0, glow: HDRColor(), opacity: 1.0)
		let grey = ColorData(ambient: HDRColor(r: 0.3,g: 0.3,b: 0.4), diffuse: HDRColor(r: 0.9,g: 0.9,b: 1.0), offset: 0.5, specular: HDRColor(r: 0.9,g: 0.9,b: 1.0), shininess: 30.0, glow: HDRColor(r: 0.1,g: 0.1,b: 0.1), opacity: 1.0)
		let darkRed = ColorData(ambient: HDRColor(r: 0.1,g: 0.05,b: 0.02), diffuse: HDRColor(r: 0.5,g: 0.2,b: 0.1), offset: 0.5, specular: HDRColor(r: 0.5,g: 0.2,b: 0.1), shininess: 20.0, glow: HDRColor(), opacity: 1.0)
		let teal = ColorData(ambient: HDRColor(r: 0.05,g: 0.1,b: 0.12), diffuse: HDRColor(r: 0.2,g: 0.5,b: 0.6), offset: 0.5, specular: HDRColor(r: 0.2,g: 0.5,b: 0.6), shininess: 100.0, glow: HDRColor(), opacity: 1.0)
		let forestGreen = ColorData(ambient: HDRColor(r: 0.0,g: 0.1,b: 0.0), diffuse: HDRColor(r: 0.0,g: 0.5,b: 0.0), offset: 0.5, specular: HDRColor(r: 0.0,g: 0.5,b: 0.0), shininess: 20.0, glow: HDRColor(), opacity: 1.0)
		let limeGreen = ColorData(ambient: HDRColor(r: 0.08,g: 0.16,b: 0.0), diffuse: HDRColor(r: 0.4,g: 0.8,b: 0.0), offset: 0.5, specular: HDRColor(r: 0.4,g: 0.8,b: 0.0), shininess: 20.0, glow: HDRColor(), opacity: 1.0)
		let matteBlue = ColorData(ambient: HDRColor(r: 0.04,g: 0.02,b: 0.14), diffuse: HDRColor(r: 0.2,g: 0.1,b: 0.7), offset: 0.5, specular: HDRColor(r: 0.2,g: 0.1,b: 0.7), shininess: 15.0, glow: HDRColor(), opacity: 1.0)
		let orange = ColorData(ambient: HDRColor(r: 0.18,g: 0.08,b: 0.0), diffuse: HDRColor(r: 0.9,g: 0.4,b: 0.0), offset: 0.5, specular: HDRColor(r: 0.9,g: 0.4,b: 0.0), shininess: 20.0, glow: HDRColor(), opacity: 1.0)
		//let babyBlue = ColorData(ambient: HDRColor(r: 0.16,g: 0.16,b: 0.16), diffuse: HDRColor(r: 0.5,g: 0.8,b: 0.8), offset: 0.5, specular: HDRColor(r: 0.5,g: 0.8,b: 0.8), shininess: 100.0, glow: HDRColor(), 1.0)
		//let pearl = ColorData(ambient: HDRColor(r: 0.16,g: 0.16,b: 0.16), diffuse: HDRColor(r: 0.8,g: 0.8,b: 0.5), offset: 0.5, specular: HDRColor(r: 0.8,g: 0.8,b: 0.5), shininess: 100.0, glow: HDRColor(), 1.0)
		
		scene.addShape(Quadric(colors: purple, position: double3(x: -20,y: 0,z: 35), equation: Equation(A: 5,B: -1,C: 5,D: 0,E: 0,F: 0,G: 0,H: 0,I: 0,J: -6)))
		
		scene.addShape(Plane(colors: yellow, position: double3(x: -60,y: 0,z: 0), normal: double3(x: 1,y: 0,z: 0)))
		
		//scene.addShape(Cylinder(colors: purple, position: double3(x: -30,y: 0,z: 0), radius: 5.0)!)
		
		scene.addShape(Sphere(colors: grey, position: double3(x: -30.0,y: 0.0,z: 0.0), radius: 11.0)!)
		scene.addShape(Sphere(colors: darkRed, position: double3(x: -30.0,y: 7.0,z: 0.0), radius: 10.0)!)
		scene.addShape(Sphere(colors: teal, position: double3(x: -30.0,y: -7.0,z: 0.0), radius: 10.0)!)
		scene.addShape(Sphere(colors: forestGreen, position: double3(x: -30.0,y: 3.0,z: 5.0), radius: 10.0)!)
		scene.addShape(Sphere(colors: limeGreen, position: double3(x: -30.0,y: -3.0,z: 5.0), radius: 10.0)!)
		scene.addShape(Sphere(colors: matteBlue, position: double3(x: -30.0,y: -3.0,z: -5.0), radius: 10.0)!)
		scene.addShape(Sphere(colors: orange, position: double3(x: -30.0,y: 3.0,z: -5.0), radius: 10.0)!)
		
		//scene.addShape(Sphere(colors: babyBlue, position: double3(x: -40.0,y: 20.0,z: -30.0), radius: 10.0)!)
		//scene.addShape(Sphere(colors: pearl, position: double3(x: -40.0,y: -20.0,z: 30.0), radius: 10.0)!)
	}

	override var representedObject: AnyObject? {
		didSet {
		// Update the view, if already loaded.
		}
	}


}


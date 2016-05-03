//
//  ViewController.swift
//  LiteRay
//
//  Created by Matthew Dillard on 4/6/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Cocoa
import simd

class ViewController: MetalViewController {
	var scene = Scene()
	var camera = Camera()
	
	@IBOutlet weak var ImageView: NSImageView!
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		
		loadReflectiveScene()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let start = NSDate()
		
		ImageView.image = camera.capture(scene, size: ImageView.bounds.size, AntiAliasing: 10, depth: 10)
		
		print("Time to run entire job: \(NSDate().timeIntervalSinceDate(start))")
	}
	
	private func loadReflectiveScene() {
		scene = Scene(ambient: HDRColor.blackColor(), shadingOffset: 1.0, refrIndex: 1.0)
		
		scene.add(PointLight(color: HDRColor(r: 0.1, g: 0.1, b: 0.1), position: float3(0,0.01,0)))
		scene.add(SpotLight(color: HDRColor(r: 0.8, g: 0.8, b: 0.8), position: float3(0,23.99,0), direction: float3(0,-1,0), angle: 30.0))
		
		// Material surfaces
		let red = Metallic(color: HDRColor.redColor())
		let white = Lambertian(color: HDRColor.whiteColor(), shininess: 1)
		let green = Lambertian(color: HDRColor.greenColor(), shininess: 1)
		let blue = Lambertian(color: HDRColor.blueColor(), shininess: 20)
		//let gunmetal = Metallic(color: HDRColor(r: 0.1, g: 0.1, b: 0.1), fuzz: 0.005)
		
		// spheres
		scene.add(Plane(material: white, position: float3(0,0,0), normal: float3(0,1,0)))	// floor
		scene.add(Sphere(material: green, position: float3(0,3,10), radius: 3)!)			// green sphere
		scene.add(Sphere(material: blue, position: float3(-170,30,100), radius: 30)!)		// in the back right
		//scene.add(Sphere(material: gunmetal, position: float3(100,70,110), radius: 70)!)	// in the back left
		
		// interpolated values
		let s0pos0 = float3(-4, 4, 20), s0pos1 = float3(-14, 4, 11)	// red
		let s1pos0 = float3(-10,6,2), s1pos1 = float3(-5,6,2)		// clear
		let s2pos0 = float3(19,18,19), s2pos1 = float3(19,18,19)	// mirror
		let camAngle0 = Float(0.0), camAngle1 = 0.4 * Float(M_PI)	// camera angle
		
		
		// get interpolated values
		let regstep = Float(0) / Float(240)
		let step = sqrt(regstep)
		
		
		// camera values
		let camPos = float3(0,8,-15)
		let camLook = float3(0,8,-14)
		
		// interpolate
		let mirror = Metallic(color: HDRColor(r: 0.6 + 0.4 * step, g: 1.0, b: 1.0), fuzz: 0.03)
		let glass = Dielectric(color: HDRColor(r: 0.7 + 0.3 * step, g: 1.0, b: 0.8 + 0.2 * step), refrIndex: 1.2)
		let s0pos = step * s0pos1 + (1 - step) * s0pos0
		let s1pos = step * s1pos1 + (1 - step) * s1pos0
		let s2pos = step * s2pos1 + (1 - step) * s2pos0
		let camAngle = regstep * camAngle1 + (1 - regstep) * camAngle0
		
		// rotations
		let mirAxis = Ray(o: s2pos, d: float3(-15,100,0))
		let newCamPos = mirAxis.rotateAbout(camPos, angle: camAngle)
		let newCamLook = (mirAxis.rotateAbout(camLook, angle: camAngle) - newCamPos).unit
		
		// positioning
		scene.add(Sphere(material: red, position: s0pos, radius: 4)!)		// red
		scene.add(Sphere(material: glass, position: s1pos, radius: 6)!)		// clear
		scene.add(Sphere(material: mirror, position: s2pos, radius: 18)!)	// mirror

		camera = Camera(position: newCamPos, lookDir: newCamLook, FOV: 95.0)		// camera
	}
	
	override var representedObject: AnyObject? {
		didSet {
		// Update the view, if already loaded.
		}
	}
}


//: Playground - noun: a place where people can play

import Cocoa
import simd

extension NSImage {
	var imagePNGRepresentation: NSData {
		return NSBitmapImageRep(data: TIFFRepresentation!)!.representationUsingType(.NSPNGFileType, properties: [:])!
	}
	func savePNG(path:String) -> Bool {
		return imagePNGRepresentation.writeToFile(path, atomically: true)
	}
}

let scene = Scene(ambient: HDRColor(r: 0.1,g: 0.1,b: 0.1), refrIndex: 1.0)

scene.add(PointLight(color: HDRColor(r: 0.1, g: 0.1, b: 0.1), position: float3(0,0.01,0)))
scene.add(SpotLight(color: HDRColor(r: 0.8, g: 0.8, b: 0.8), position: float3(0,23.99,0), direction: float3(0,-1,0), angle: 65.0))

let white = ColorData(ambient: HDRColor(r: 0.5,g: 0.5,b: 0.5), diffuse: HDRColor(r: 0.5,g: 0.5,b: 0.5), specular: HDRColor(r: 0.5,g: 0.5,b: 0.5), shininess: 3.0)
let red = ColorData(ambient: HDRColor(r: 0.1,g: 0.05,b: 0.02), diffuse: HDRColor(r: 0.5,g: 0.2,b: 0.1), specular: HDRColor(r: 0.5,g: 0.2,b: 0.1), shininess: 20.0)
let green = ColorData(ambient: HDRColor(r: 0.0,g: 0.1,b: 0.0), diffuse: HDRColor(r: 0.0,g: 0.5,b: 0.0), offset: 0.0, specular: HDRColor(r: 0.0,g: 0.5,b: 0.0), shininess: 100.0)

let mirror = ColorData(reflectivity: 1.0)

let glass = ColorData(opacity: 0.0, refrIndex: 1.25)

// spheres
scene.add(Sphere(colors: glass, position: float3(-6,4,2), radius: 4)!) // right
scene.add(Sphere(colors: mirror, position: float3(6,3,8), radius: 3)!) // left
scene.add(Sphere(colors: mirror, position: float3(0,1,10), radius: 1)!) // center
scene.add(Quadric(colors: glass, position: float3(0,12,5), equation: Equation(A: -1, B: 5, C: 5, D: 1, G: 0, J: 25)))

// walls
scene.add(Plane(colors: white, position: float3(0,24,0), normal: float3(0,-1,0))) // ceiling
scene.add(Plane(colors: red, position: float3(12,0,0), normal: float3(-1,0,0))) // left
scene.add(Plane(colors: white, position: float3(0,0,12), normal: float3(0,0,-1))) // front
scene.add(Plane(colors: green, position: float3(-12,0,0), normal: float3(1,0,0))) // right
scene.add(Plane(colors: white, position: float3(0,0,-12), normal: float3(0,0,1))) // back
scene.add(Plane(colors: white, position: float3(0,0,0), normal: float3(0,1,0))) // floor

let cam = Camera(position: float3(0,8,-10), lookDir: float3(0,0,1), FOV: 110.0, nearClip: 0.1, farClip: 1000.0)

//let image1 = cam.capture(scene, size: NSSize(width: 600, height: 500), AntiAliasing: 1)

for x in 0...10 {
	let cam = Camera(position: float3(0,8,-10 + 0.2 * Float(x)), lookDir: float3(0,0,1), FOV: 110.0, nearClip: 0.1, farClip: 1000.0)

	let image = cam.capture(scene, size: NSSize(width: 600, height: 500), AntiAliasing: 10)

	if !image.savePNG("/Users/Matt/Pictures/snapshot\(x).png") {
		print("error saving png file")
	}
}

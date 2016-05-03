//
//  Document.swift
//  LiteRay
//
//  Created by Matthew Dillard on 4/10/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Cocoa
import simd

class Document: NSDocument {
	var scene = Scene()
	var camera = Camera()
	
	
	// MARK: Begin NSDocument subclassing
	
	override init() {
	    super.init()
		
		loadSimpleScene(6.0/24.0)
	}
	
	override class func autosavesInPlace() -> Bool {
		return true
	}
	
	override func makeWindowControllers() {
		// Returns the Storyboard that contains your Document window.
		let storyboard = NSStoryboard(name: "Main", bundle: nil)
		let windowController = storyboard.instantiateControllerWithIdentifier("Document Window Controller") as! NSWindowController
		self.addWindowController(windowController)
	}
	
	override func dataOfType(typeName: String) throws -> NSData {
		// Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
		// You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
		
		let root = NSXMLElement(name: "root")
		let xml = NSXMLDocument(rootElement: root)
		
		xml.documentContentKind = NSXMLDocumentContentKind.XMLKind
		
		let sec = NSXMLElement(name: "foo")
		let thi = NSXMLElement(name: "la")
		thi.addChild(NSXMLElement(name: "extra", stringValue:"pow"))
		sec.addChild(thi)
		root.addChild(sec)
		
		return xml.XMLDataWithOptions(NSXMLNodePrettyPrint | NSXMLDocumentIncludeContentTypeDeclaration)
	}
	
	override func readFromData(data: NSData, ofType typeName: String) throws {
		// Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
		// You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
		// If you override either of these, you should also override -isEntireFileLoaded to return false if the contents are lazily loaded.
		
		guard let doc = try? NSXMLDocument(data: data, options: 0) else {
			print("cant load XML file")
			throw NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
		}
		
		print(doc)
	}
	
	
	// MARK: Testable scenes
	
	private func loadSimpleScene(interval: Float) {
		scene = Scene(ambient: HDRColor.blackColor(), shadingOffset: 0.0, refrIndex: 1.0)
		
		scene.add(PointLight(color: HDRColor(r: 0.1, g: 0.1, b: 0.1), position: float3(0,0.01,0)))
		scene.add(SpotLight(color: HDRColor(r: 0.8, g: 0.8, b: 0.8), position: float3(0,23.99,0), direction: float3(0,-1,0), angle: 65.0))
		
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
		let step = sqrt(interval)
		
		
		// camera values
		let camPos = float3(0,8,-15)
		let camLook = float3(0,8,-14)
		
		// interpolate
		let mirror = Metallic(color: HDRColor(r: 0.6 + 0.4 * step, g: 1.0, b: 1.0), fuzz: 0.03)
		let glass = Dielectric(color: HDRColor(r: 0.7 + 0.3 * step, g: 1.0, b: 0.8 + 0.2 * step), refrIndex: 1.2)
		let s0pos = step * s0pos1 + (1 - step) * s0pos0
		let s1pos = step * s1pos1 + (1 - step) * s1pos0
		let s2pos = step * s2pos1 + (1 - step) * s2pos0
		let camAngle = interval * camAngle1 + (1 - interval) * camAngle0
		
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
}


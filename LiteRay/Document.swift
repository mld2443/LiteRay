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
	
	
	// MARK: Begin NSDocument subclassing
	
	override init() {
	    super.init()
		
		// Testing for saving a scene.
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
}


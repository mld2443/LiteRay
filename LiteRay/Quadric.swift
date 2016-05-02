//
//  Quadric.swift
//  LiteRay
//
//  Created by Matthew Dillard on 3/12/16.
//  Copyright © 2016 Matthew Dillard. All rights reserved.
//

import Foundation
import simd

/// Describes an equation of a 2nd degree polynomial of the form:
///
///     Ax² + By² + Cz² + 2Dyz + 2Exz + 2Fxy + 2Gx + 2Hy + 2Iz + J = 0
///
/// - seealso:
/// - [Wolfram MathWorld Quadratic Surface description](http://mathworld.wolfram.com/QuadraticSurface.html)
/// - [Wikipedia page on Quadrics](https://en.wikipedia.org/wiki/Quadric)
public struct Equation {
	let A: Float, B: Float, C: Float
	let D: Float, E: Float, F: Float
	let G: Float, H: Float, I: Float
	let J: Float
	
	public init(A: Float = 0.0, B: Float = 0.0, C: Float = 0.0, D: Float = 0.0, E: Float = 0.0, F: Float = 0.0, G: Float = 0.0, H: Float = 0.0, I: Float = 0.0, J: Float = 0.0) {
		self.A = A; self.B = B; self.C = C
		self.D = D; self.E = E; self.F = F
		self.G = G; self.H = H; self.I = I
		self.J = J
	}
	
	public var ABC: float3 { return float3(x: A, y: B, z: C) }
	public var DEF: float3 { return float3(x: D, y: E, z: F) }
	public var GHI: float3 { return float3(x: G, y: H, z: I) }
}

/// Quadric shape, describes 2nd degree polynomial surfaces
public class Quadric : Shape {
	public var material: Material
	public var position: float3
	let equation: Equation
	
	public var normTransform: ((Intersection) -> Intersection)?
	
	/// Initializes a quadric
	/// - Parameters:
	///   - ColorData: Phong shading description
	///   - float3: point of origin for the quadric
	///   - Equation: equation of the quadric shape
	public init(material: Material, position: float3, equation: Equation) {
		self.material = material
		self.position = position
		self.equation = equation
	}
	
	internal func getNormal(at point: float3) -> float3 {
		var relative:float3 = point - position, normal:float3 = float3()
		normal.x = 2 * equation.A * relative.x + equation.E * relative.z + equation.F * relative.y + equation.G
		normal.y = 2 * equation.B * relative.y + equation.D * relative.z + equation.F * relative.x + equation.H
		normal.z = 2 * equation.C * relative.z + equation.D * relative.y + equation.E * relative.x + equation.I
		return normal.unit
	}
	
	/// Calculates a ray intersection with the quadric
	/// - note: I use the algorithm described [here](http://users.wowway.com/~phkahler/quadrics.pdf)
	/// - Parameters:
	///   - Ray: the ray upon which to test intersection
	/// - Returns: the shortest distance along that ray to intersection or `nil` if there is no intersection
	internal func calcIntersection(ray: Ray, frustrum: (near: Float, far: Float)) -> Float? {
		// Calculate the positions of the camera and the ray relative to the quadric
		let rCam = ray.o - position
		let rRay = ray.d
		
		// Precalculate these values for our quadratic equation
		let V1 = rRay * rRay
		let V2 = 2 * float3(x: rRay.x * rRay.y, y: rRay.y * rRay.z, z: rRay.x * rRay.z)
		let V3 = rCam * rRay
		let V4 = float3(x: rRay.x * rCam.y + rCam.x * rRay.y, y: rCam.y * rRay.z + rRay.y * rCam.z, z: rCam.x * rRay.z + rRay.x * rCam.z)
		let V5 = rRay
		let V6 = rCam * rCam
		let V7 = 2 * float3(x: rCam.x * rCam.y, y: rCam.y * rCam.z, z: rCam.x * rCam.z)
		let V8 = 2 * rCam
		
		// Calculate the quadratic coefficients
		let A = equation.ABC • V1 + equation.DEF • V2
		let B = equation.ABC • V3 + equation.DEF • V4 + equation.GHI • V5
		let C = equation.ABC • V6 + equation.DEF • V7 + equation.GHI • V8 + equation.J
		
		// Calculate the root value for our quadratic formula
		var root = (B * B) - (A * C)
		
		// No collision if the root is imaginary
		if (root < 0) {
			return nil
		}
		
		// Take its root if it's real
		root = sqrt(root)
		
		// Calculate both intersections
		let D1 = (-B - root)/A
		let D2 = (-B + root)/A
		
		// Return closest intersection thats in the frustrum
		if D1 < frustrum.far && D1 > frustrum.near {
			return D1
		}
		else if D2 < frustrum.far && D2 > frustrum.near {
			return D2
		}
		
		return nil
	}
	
	/// Calculates a ray intersection with the quadric
	/// - note: I use the algorithm described [here](http://users.wowway.com/~phkahler/quadrics.pdf)
	/// - Parameters:
	///   - Ray: the ray upon which to test intersection
	/// - Returns: the shortest distance along that ray to intersection or `nil` if there is no intersection
	public func intersectRay(ray: Ray, frustrum: (near: Float, far: Float)) -> Intersection? {
		guard let depth = calcIntersection(ray, frustrum: frustrum) else {
			return nil
		}
		
		let point = (ray * depth).o
		
		let intersect = Intersection(dist: depth, point: point, norm: self.getNormal(at: point), material: self.material)
		
		if normTransform != nil {
			return normTransform!(intersect)
		}
		
		return intersect
	}
}

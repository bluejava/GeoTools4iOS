//
//  SCNUtils.swift
//  GeoTools4iOS
//
//  Created by Glenn Crownover on 5/4/15.
//  Copyright (c) 2015 bluejava. All rights reserved.
//

import SceneKit

class SCNUtils
{
	class func getNodeFromDAE(name: String) -> SCNNode?
	{
		var rnode = SCNNode()
		let nscene = SCNScene(named: name)
		
		if let nodeArray = nscene?.rootNode.childNodes
		{
			for cn in nodeArray {
				rnode.addChildNode(cn as! SCNNode)
			}
			return rnode
		}
		
		println("DAE File not found: \(name)!!")
		
		return nil
	}
	
	class func getStaticNodeFromDAE(name: String) -> SCNNode?
	{
		if let node = getNodeFromDAE(name)
		{
			//			debugNode(node)
			node.physicsBody = SCNPhysicsBody(type: .Static, shape: SCNPhysicsShape(node: node, options: [ SCNPhysicsShapeTypeKey: SCNPhysicsShapeTypeConcavePolyhedron]))
			return node
		}
		
		return nil
	}
	
	class func debugNode(node: SCNNode)
	{
		println("node: \(node.name)")
		for cn in node.childNodes
		{
			debugNode(cn as! SCNNode)
		}
	}
	
	class func getMat(textureFilename: String, ureps: Float = 1.0, vreps: Float = 1.0, directory: String? = nil,
		normalFilename: String? = nil, specularFilename: String? = nil) -> SCNMaterial
	{
		var nsb = NSBundle.mainBundle().pathForResource(textureFilename, ofType: nil, inDirectory: directory)
		let im = UIImage(contentsOfFile: nsb!)
		
		let mat = SCNMaterial()
		mat.diffuse.contents = im
		
		if(normalFilename != nil)
		{
			mat.normal.contents = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource(normalFilename, ofType: nil, inDirectory: directory)!)
		}
		
		if(specularFilename != nil)
		{
			mat.specular.contents = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource(specularFilename, ofType: nil, inDirectory: directory)!)
		}
		
		repeatMat(mat, wRepeat: ureps,hRepeat: vreps)
		
		return mat
	}
	
	class func repeatMat(mat: SCNMaterial, wRepeat: Float, hRepeat: Float)
	{
		mat.diffuse.contentsTransform = SCNMatrix4MakeScale(wRepeat, hRepeat, 1.0)
		mat.diffuse.wrapS = .Repeat
		mat.diffuse.wrapT = .Repeat
		
		mat.normal.wrapS = .Repeat
		mat.normal.wrapT = .Repeat
		
		mat.specular.wrapS = .Repeat
		mat.specular.wrapT = .Repeat
	}
	
	// Return the normal against the plane defined by the 3 vertices, specified in 
	// counter-clockwise order.
	// note, this is an un-normalized normal.  (ha.. wtf? yah, thats right)
	class func getNormal(v0: SCNVector3, v1: SCNVector3, v2: SCNVector3) -> SCNVector3
	{
		// there are three edges defined by these 3 vertices, but we only need 2 to define the plane
		var edgev0v1 = v1 - v0
		var edgev1v2 = v2 - v1
		
		// Assume the verts are expressed in counter-clockwise order to determine normal
		return edgev0v1.cross(edgev1v2)
	}
}

// The following SCNVector3 extension comes from https://github.com/devindazzle/SCNVector3Extensions - with some changes by me

extension CGPoint
{
	init(x: Float, y: Float)
	{
		self.init(x: CGFloat(x), y: CGFloat(y))
	}
}

extension SCNVector3
{
	/**
	* Negates the vector described by SCNVector3 and returns
	* the result as a new SCNVector3.
	*/
	func negate() -> SCNVector3 {
		return self * -1
	}
	
	/**
	* Negates the vector described by SCNVector3
	*/
	mutating func negated() -> SCNVector3 {
		self = negate()
		return self
	}
	
	/**
	* Returns the length (magnitude) of the vector described by the SCNVector3
	*/
	func length() -> Float {
		return sqrt(x*x + y*y + z*z)
	}
	
	/**
	* Normalizes the vector described by the SCNVector3 to length 1.0 and returns
	* the result as a new SCNVector3.
	*/
	func normalized() -> SCNVector3? {
		
		var len = length()
		if(len > 0)
		{
			return self / length()
		}
		else
		{
			return nil
		}
	}
	
	/**
	* Normalizes the vector described by the SCNVector3 to length 1.0.
	*/
	mutating func normalize() -> SCNVector3? {
		if let vn = normalized()
		{
			self = vn
			return self
		}
		return nil
	}
	
	/**
	* Calculates the distance between two SCNVector3. Pythagoras!
	*/
	func distance(vector: SCNVector3) -> Float {
		return (self - vector).length()
	}
	
	/**
	* Calculates the dot product between two SCNVector3.
	*/
	func dot(vector: SCNVector3) -> Float {
		return x * vector.x + y * vector.y + z * vector.z
	}
	
	/**
	* Calculates the cross product between two SCNVector3.
	*/
	func cross(vector: SCNVector3) -> SCNVector3 {
		return SCNVector3Make(y * vector.z - z * vector.y, z * vector.x - x * vector.z, x * vector.y - y * vector.x)
	}
	
	func toString() -> String
	{
		return "SCNVector3(x:\(x), y:\(y), z:\(z)"
	}
	
	// Return the angle between this vector and the specified vector v
	func angle(v: SCNVector3) -> Float
	{
		// angle between 3d vectors P and Q is equal to the arc cos of their dot products over the product of
		// their magnitudes (lengths).
		//	theta = arccos( (P • Q) / (|P||Q|) )
		let dp = dot(v) // dot product
		let magProduct = length() * v.length() // product of lengths (magnitudes)
		return acos(dp / magProduct) // DONE
	}
	
	mutating func constrain(min: SCNVector3, max: SCNVector3) -> SCNVector3 {
		if(x < min.x) { self.x = min.x }
		if(x > max.x) { self.x = max.x }
		
		if(y < min.y) { self.y = min.y }
		if(y > max.y) { self.y = max.y }
		
		if(z < min.z) { self.z = min.z }
		if(z > max.z) { self.z = max.z }
		
		return self
	}
}

/**
* Adds two SCNVector3 vectors and returns the result as a new SCNVector3.
*/
func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
	return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

/**
* Increments a SCNVector3 with the value of another.
*/
func += (inout left: SCNVector3, right: SCNVector3) {
	left = left + right
}

/**
* Subtracts two SCNVector3 vectors and returns the result as a new SCNVector3.
*/
func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
	return SCNVector3Make(left.x - right.x, left.y - right.y, left.z - right.z)
}

/**
* Decrements a SCNVector3 with the value of another.
*/
func -= (inout left: SCNVector3, right: SCNVector3) {
	left = left - right
}

/**
* Multiplies two SCNVector3 vectors and returns the result as a new SCNVector3.
*/
func * (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
	return SCNVector3Make(left.x * right.x, left.y * right.y, left.z * right.z)
}

/**
* Multiplies a SCNVector3 with another.
*/
func *= (inout left: SCNVector3, right: SCNVector3) {
	left = left * right
}

/**
* Multiplies the x, y and z fields of a SCNVector3 with the same scalar value and
* returns the result as a new SCNVector3.
*/
func * (vector: SCNVector3, scalar: Float) -> SCNVector3 {
	return SCNVector3Make(vector.x * scalar, vector.y * scalar, vector.z * scalar)
}

/**
* Multiplies the x and y fields of a SCNVector3 with the same scalar value.
*/
func *= (inout vector: SCNVector3, scalar: Float) {
	vector = vector * scalar
}

/**
* Divides two SCNVector3 vectors abd returns the result as a new SCNVector3
*/
func / (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
	return SCNVector3Make(left.x / right.x, left.y / right.y, left.z / right.z)
}

/**
* Divides a SCNVector3 by another.
*/
func /= (inout left: SCNVector3, right: SCNVector3) {
	left = left / right
}

/**
* Divides the x, y and z fields of a SCNVector3 by the same scalar value and
* returns the result as a new SCNVector3.
*/
func / (vector: SCNVector3, scalar: Float) -> SCNVector3 {
	return SCNVector3Make(vector.x / scalar, vector.y / scalar, vector.z / scalar)
}

/**
* Divides the x, y and z of a SCNVector3 by the same scalar value.
*/
func /= (inout vector: SCNVector3, scalar: Float) {
	vector = vector / scalar
}

/**
* Calculates the SCNVector from lerping between two SCNVector3 vectors
*/
func SCNVector3Lerp(vectorStart: SCNVector3, vectorEnd: SCNVector3, t: Float) -> SCNVector3 {
	return SCNVector3Make(vectorStart.x + ((vectorEnd.x - vectorStart.x) * t), vectorStart.y + ((vectorEnd.y - vectorStart.y) * t), vectorStart.z + ((vectorEnd.z - vectorStart.z) * t))
}

/**
* Project the vector, vectorToProject, onto the vector, projectionVector.
*/
func SCNVector3Project(vectorToProject: SCNVector3, projectionVector: SCNVector3) -> SCNVector3 {
	let scale: Float = projectionVector.dot(vectorToProject) / projectionVector.dot(projectionVector)
	let v: SCNVector3 = projectionVector * scale
	return v
}

// Define a couple structures that hold GLFloats (3 and 2)
struct Float3 { var x, y, z: GLfloat }
struct Float2 { var s, t: GLfloat }

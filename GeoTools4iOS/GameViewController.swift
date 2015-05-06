//
//  GameViewController.swift
//  GeoTools4iOS
//
//  Created by Glenn Crownover on 5/4/15.
//  Copyright (c) 2015 bluejava. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		
		/* First, some boilerplate SceneKit setup - lights, camera, (action comes later)  */
		
		// create a new scene
		var scene = SCNScene()
		
		var rootNode = scene.rootNode
		
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 15)
		
		// create and add a light to the scene
		let lightNode = SCNNode()
		lightNode.light = SCNLight()
		lightNode.light!.type = SCNLightTypeOmni
		lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
		rootNode.addChildNode(lightNode)
		
		// create and add an ambient light to the scene
		let ambientLightNode = SCNNode()
		ambientLightNode.light = SCNLight()
		ambientLightNode.light!.type = SCNLightTypeAmbient
		ambientLightNode.light!.color = UIColor.darkGrayColor()
		rootNode.addChildNode(ambientLightNode)
		
		/*
		Here are the actual custom geometry test functions
		*/
		
		textureTileExample(scene.rootNode)			// A parallelogram with stretched texture
		textureTileExampleNonPar(scene.rootNode)	// A non-parallel quadrilateral shape with tiled texture
		textureTileExample3d(scene.rootNode)		// A 3d custom shape with tiled texture
		
		/*  Now, some more boilerplate…  */
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.whiteColor()
    }
	
	
	// Always keep in mind the orientation of the verticies when looking at the face from the "front"
	// With single-sided faces, we only see from the front side - so this is important.
	//  v1 --------------v0
	//  |             __/ |
	//  | face     __/    |
	//  | 1     __/       |
	//  |    __/     face |
	//  | __/           2 |
	//  v2 ------------- v3
	// Two triangular faces are created from the 4 vertices - think of drawing the letter C when considering the order
	// to enter your vertices - top right, then top left, then bottom left, then bottom right - But of course, this is
	// relative only to your field of view - not the global coordinate system - "bottom" for your shape may be "up" in
	// the world view!
	
	// This function creates a quadrilateral shape with non-parallel sides. Note how the
	// texture originates at v2 and tiles to the right, up and to the left seamlessly.
	func textureTileExample(pnode: SCNNode)
	{
		// First, we create the 4 vertices for our custom geometry - note, they share a plane, but are otherwise irregular
		var v0 = SCNVector3(x: 6, y: 6, z: 0)
		var v1 = SCNVector3(x: 0, y: 6, z: 0)
		var v2 = SCNVector3(x: 0, y: 0, z: 0)
		var v3 = SCNVector3(x: 6, y: 0, z: 0)
		
		// Now we create the GeometryBuilder - which allows us to add quads  to make up a custom shape
		var geobuild = GeometryBuilder(uvMode: GeometryBuilder.UVModeType.StretchToFitXY)
		
		geobuild.addQuad(Quad(v0: v0,v1: v1,v2: v2,v3: v3)) // only the one quad for us today, thanks!
		var geo = geobuild.getGeometry()					// And here we get an SCNGeometry instance from our new shape
		
		// Lets setup the diffuse, normal and specular maps - located in a subdirectory
		geo.materials = [ SCNUtils.getMat("diffuse.jpg", normalFilename: "normal.jpg", specularFilename: "specular.jpg", directory: "textures/brickTexture") ]
		
		// Now we simply create the node, position it, and add to our parent!
		var node = SCNNode(geometry: geo)
		node.position = SCNVector3(x: 5, y: 2, z: 0)
		
		pnode.addChildNode(node)
	}

	func textureTileExampleFlipped(pnode: SCNNode)
	{
		// First, we create the 4 vertices for our custom geometry - note, they share a plane, but are otherwise irregular
		var v0 = SCNVector3(x: 6, y: 0, z: 0)
		var v1 = SCNVector3(x: 0, y: 0, z: 0)
		var v2 = SCNVector3(x: 0, y: 6, z: 0)
		var v3 = SCNVector3(x: 6, y: 6, z: 0)
		
		// Now we create the GeometryBuilder - which allows us to add quads  to make up a custom shape
		var geobuild = GeometryBuilder(uvMode: GeometryBuilder.UVModeType.StretchToFitXY)
		
		geobuild.addQuad(Quad(v0: v0,v1: v1,v2: v2,v3: v3)) // only the one quad for us today, thanks!
		var geo = geobuild.getGeometry()					// And here we get an SCNGeometry instance from our new shape
		
		// Lets setup the diffuse, normal and specular maps - located in a subdirectory
		geo.materials = [ SCNUtils.getMat("diffuse.jpg", normalFilename: "normal.jpg", specularFilename: "specular.jpg", directory: "textures/brickTexture") ]
		
		// Now we simply create the node, position it, and add to our parent!
		var node = SCNNode(geometry: geo)
		node.position = SCNVector3(x: 5, y: 2, z: 0)
		
		pnode.addChildNode(node)
	}
	
	
	// This function creates a quadrilateral shape with parallel sides to demonstrate
	// a stretchedToFit texture mapping. Of course, since it is non-square, the texture is
	// skewed.
	func textureTileExampleNonPar(pnode: SCNNode)
	{
		var v0 = SCNVector3(x: 6, y: 6.0, z: 6)
		var v1 = SCNVector3(x: 1, y: 4, z: 1)
		var v2 = SCNVector3(x: 2, y: 0, z: 2)
		var v3 = SCNVector3(x: 5, y: -2, z: 5)
		
		var geobuild = GeometryBuilder(uvMode: GeometryBuilder.UVModeType.StretchToFitXY)
		geobuild.addQuad(Quad(v0: v0,v1: v1,v2: v2,v3: v3)) // simple
		var geo = geobuild.getGeometry()
		
		geo.materials = [ SCNUtils.getMat("diffuse.jpg", normalFilename: "normal.jpg", specularFilename: "specular.jpg", directory: "textures/brickTexture") ]
		
		var node = SCNNode(geometry: geo)
		node.position = SCNVector3(x: 5, y: -6, z: 0)
		
		pnode.addChildNode(node)
	}
	
	func testQ3D(pnode: SCNNode)
	{
		var node = buildQuad3D([
			SCNVector3(x: 4,y: 4,z: -4),
			SCNVector3(x: 0,y: 4,z: -4),
			SCNVector3(x: 0,y: 4,z: 0),
			SCNVector3(x: 4,y: 4,z: 0),
			
			SCNVector3(x: 4,y: 1,z: 0),
			SCNVector3(x: 0,y: 1,z: 0),
			SCNVector3(x: 0,y: 1,z: -4),
			SCNVector3(x: 4,y: 1,z: -4),
			])
		
		//		node.geometry?.materials = [ SCNUtils.getMat("diffuse.jpg", normalFilename: "normal.jpg", specularFilename: "specular.jpg", directory: "3d textures/brickTexture") ]
		node.geometry?.firstMaterial?.diffuse.contents = UIColor.purpleColor()
		
		node.position = SCNVector3(x: 4, y: 4.0, z: -4)
		
		pnode.addChildNode(node)
		
		//		var xx = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1))
		//		xx.geometry?.firstMaterial!.diffuse.contents = UIColor.redColor()
		//		xx.position.y = 8
		//		pnode.addChildNode(xx)
	}
	
	
	func buildQuad3D(v: [SCNVector3]) -> SCNNode
	{
		var geobuild = GeometryBuilder(uvMode: .SizeToWorldUnitsXY)
		
		geobuild.addQuad(Quad(v0: v[3],v1: v[2],v2: v[5],v3: v[4])) // front
		geobuild.addQuad(Quad(v0: v[2],v1: v[1],v2: v[6],v3: v[5])) // left
		geobuild.addQuad(Quad(v0: v[0],v1: v[3],v2: v[4],v3: v[7])) // right
		geobuild.addQuad(Quad(v0: v[1],v1: v[0],v2: v[7],v3: v[6])) // back
		geobuild.addQuad(Quad(v0: v[0],v1: v[1],v2: v[2],v3: v[3])) // top
		geobuild.addQuad(Quad(v0: v[4],v1: v[5],v2: v[6],v3: v[7])) // bottom
		
		var geo = geobuild.getGeometry()
		
		return SCNNode(geometry: geo)
	}
	
	// And finally, here is a full 3d object with six sides.  We only create the 8 vertices of the shape once,
	// but they are replicated for each quad and then for each face as they have their own normals, texture coordinates, etc.
	// But it sure makes our job easy at this point - just enter your vertices, build your quads and generate the shape!
	func textureTileExample3d(pnode: SCNNode)
	{
		var f0 = SCNVector3(x: 6, y: 6.0, z: 2)
		var f1 = SCNVector3(x: 1, y: 4, z: 2)
		var f2 = SCNVector3(x: 2, y: 0, z: 2)
		var f3 = SCNVector3(x: 5, y: -2, z: 2)
		
		var b0 = SCNVector3(x: 6, y: 6.0, z: 0)
		var b1 = SCNVector3(x: 1, y: 4, z: 0)
		var b2 = SCNVector3(x: 2, y: 0, z: 0)
		var b3 = SCNVector3(x: 5, y: -2, z: 0)
		
		// Note: This uvMode will consider 1 by 1 coordinate units to coorespond with one full texture.
		// This works great for drawing large irregularly shaped objects made with tile-able textures.
		// The textures tile across each face without stretching or skewing regardless of size.
		var geobuild = GeometryBuilder(uvMode: .SizeToWorldUnitsXY)
		geobuild.addQuad(Quad(v0: f0,v1: f1,v2: f2,v3: f3)) // front
		geobuild.addQuad(Quad(v0: b1,v1: b0,v2: b3,v3: b2)) // back
		geobuild.addQuad(Quad(v0: b0,v1: b1,v2: f1,v3: f0)) // top
		geobuild.addQuad(Quad(v0: f1,v1: b1,v2: b2,v3: f2)) // left
		geobuild.addQuad(Quad(v0: b0,v1: f0,v2: f3,v3: b3)) // right
		geobuild.addQuad(Quad(v0: f3,v1: f2,v2: b2,v3: b3)) // bottom
		
		var geo = geobuild.getGeometry()
		
		geo.materials = [ SCNUtils.getMat("diffuse.jpg", normalFilename: "normal.jpg", specularFilename: "specular.jpg", directory: "textures/brickTexture") ]
		
		var node = SCNNode(geometry: geo)
		node.position = SCNVector3(x: -5, y: 2, z: 0)
		
		pnode.addChildNode(node)
	}
	
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}

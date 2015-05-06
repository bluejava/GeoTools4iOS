//
//  Quad.swift
//  GeoTools4iOS
//
//  Created by Glenn Crownover on 5/4/15.
//  Copyright (c) 2015 bluejava. All rights reserved.
//

// A four vertice quad - must either be planar, or if non-planar, note that the
// shared edge will be v0->v2
//
//  v1 --------v0
//  |        _/ |
//  |      _/   |
//  |    _/     |
//  |  _/       |
//  | /         |
//  v2 ------- v3

import SceneKit

class Quad
{
	let v0: SCNVector3
	let v1: SCNVector3
	let v2: SCNVector3
	let v3: SCNVector3
	
	init(v0: SCNVector3, v1: SCNVector3, v2: SCNVector3, v3: SCNVector3)
	{
		self.v0 = v0
		self.v1 = v1
		self.v2 = v2
		self.v3 = v3
	}
	
	class func vector3ToFloat3(vector3: SCNVector3) -> Float3
	{
		return Float3(x: vector3.x, y: vector3.y, z: vector3.z)
	}
}


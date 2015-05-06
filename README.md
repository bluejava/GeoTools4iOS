# GeoTools4iOS

**A Swift Library to Aid in the Creation of Custom Geometry for SceneKit (iOS)**

**Note:** This is the iOS version of this same set of tools for OS X called [GeoTools](https://github.com/bluejava/GeoTools)  Having separate projects is necessary to allow for the changes between Cocoa and Cocoa Touch - but also a change was required in the defining of geometry due to a bug in the iOS implementation of SceneKit which caused texture mapping to break.

What follows is exactly the same as the README for [GeoTools](https://github.com/bluejava/GeoTools):

------

Use this very small library (currently just 3 classes) to easily build custom geometry in your Swift-based SceneKit projects for OS X (iOS version soon to follow). It uses the concept of "Quads" rather than "Triangles" to build up your geometry, making it easier to visualize, create and texture map shapes.  It also offers support for tiling your textures across "odd" shapes without skewing.

![Custom Geometry Example](http://www.bluejava.com/int/images/GeoTools01.jpg "Custom Geometry Example")

*The example above is a custom 4-sided geometry with a tiled texture.*

## Project Goals

My goal was to make it as simple as possible to build complex custom geometries with minimal code. I also wanted to enable tiling texture mapping that is sensitive to geometry

## How to Use
Building custom geometry entails creating a `GeometryBuilder` instance - adding `Quad` objects to it to form your shape, then calling `getGeometry()` on it to obtain your geometry. I based it on Quads (though internally the mesh is built using Triangles) - as it is easier to think of custom shapes as built up from quads.

```
    v1 --------------v0
    |             __/ |
    |          __/    |
    |       __/       |
    |    __/          |
    | __/             |
    v2 ------------- v3
```

A `Quad` is made up of four vertices on a plane which make up a quadrilateral shape.  Think of vertices as labeled v0 through v3 - starting with v0 at the upper right corner - v1 at upper left - v2 at bottom left - and v3 at lower right, as illustrated above. The opposing edges need not be parallel of course, allowing for shapes such as the textured brick one above.

**Note:** The order of defining your vertices is important. The order determines the "normal" of the face which dictates which side of the face is visible.  My code assumes a counter-clockwise order of vertices as illustrated above. I always think of drawing the letter *C* while staring towards the visible side of the face. Also keep in mind that the upper/lower/left/right referred to here is not related to the world geometry, but only to the face you are defining.

### Code Example:

```Swift
  // First, define the four vertices of a Quad
	var v0 = SCNVector3(x: 6, y: 6.0, z: 6)
	var v1 = SCNVector3(x: 1, y: 4, z: 1)
	var v2 = SCNVector3(x: 2, y: 0, z: 2)
	var v3 = SCNVector3(x: 5, y: -2, z: 5)

	// Instantiate a GeometryBuilder and add a Quad
	var geobuild = GeometryBuilder()
	geobuild.addQuad(Quad(v0: v0,v1: v1,v2: v2,v3: v3))

	// And here is our new Geometry
	var geo = geobuild.getGeometry()

  // Now we can simply create a node using that geometry
	var node = SCNNode(geometry: geo)
```

That's it - the above code will create a node with the quadrilateral shaped plane visible from one side only.  Of course you can add materials and textures to the geometry just like any other.

## Texture Mapping
Internally, texture mapping is done by defining where in your texture image each of the 3 vertices that make up the Triangle with 0 referring to left or bottom of the image, and 1.0 referring to the right or top edge of your image. To tile a texture such as the bricks shown above without skewing requires some calculation for non-aligned boundaries. The library does this for you (if requested) by considering each unit of world space to be one edge of the texture.

Control texture mapping by passing the optional uvMode into the `GeometryBuilder`. Currently recognized options are `StretchToFitXY` and `SizeToWorldUnitsXY`.

### StretchToFitXY

```Swift
var geobuild = GeometryBuilder(uvMode: GeometryBuilder.UVModeType.StretchToFitXY)
```

This tells the GeometryBuilder to stretch the texture to each corner of the `Quad`. This can work well when your shape is square or your texture was created for that specific shape - but can often have undesireable effects when it does not:

![Custom Geometry Example](http://www.bluejava.com/int/images/GeoTools02.jpg "Custom Geometry Example")

Note the skewing in the parallelogram and the angled discontinuity occuring at the diagonal edge in the non-parallelogram shape.

### SizeToWorldUnitsXY

```Swift
var geobuild = GeometryBuilder(uvMode: GeometryBuilder.UVModeType.SizeToWorldUnitsXY)
```

This option considers your texture to be a single unit in "width" and "height" (U and V), then tiles across your shape without skewing or distortion. This is very useful when you have a material pattern (such as fabric, brick, stones, cement, steel, etc.) and wish to tile it across a complex shape realistically:

![SizeToWorldUnitsXY Example](http://www.bluejava.com/int/images/GeoTools03.jpg "SizeToWorldUnitsXY Example")

The bottom left corner is alligned with the *V2* vertice in your `Quad` and then it tiles up, to the right, and to the left seamlessly, with each one unit square getting one complete tile of the texture.


### About this project

I am working on a project (a game) that requires custom mesh geometry using Swift and SceneKit. When I began looking into how to do this I found the documentation somewhat incomplete, and I didn't find any complete examples which also covered texture mapping and/or dealt with some of the idiosyncrasies of doing it in Swift. So once I figured it out and got things working I thought maybe others could benefit from this as well.

I actually needed this functionality for iOS, but was working through this issue on OS X (for convenience/efficiency sake). Once I had it working on OS X I moved it to my iOS project, and there were problems with the textures. I believe this is a bug in the iOS implementation of SceneKit for texture mapping. I have since solved that problem and will publish that as a separate project here.
import app;
import std.math;
import NewHeightMapGenSystem;
import std.stdio;

//general info
immutable int mapSize = 2049;
immutable Point mapCenter = Point(1024,1024+128);
immutable double mapDefaultHeight = 10;

///centerCircle
immutable double centerCircleRadius = 256+128;
immutable double centerCircleMinHeight = mapDefaultHeight;
immutable double centerCirleMaxHieght = 30;
immutable double centerCircleSlope = .5f;
immutable int centerCirclePriority = 1;
immutable HowToHandleNewHeight centerCircleHeightHandling = HowToHandleNewHeight.OVER_WRITE_PREVIOUS_VALUE;

///spokes
immutable double[] spokeRotations = [((2*PI)*(0f/3f)), ((2*PI)*(1f/3f)), ((2*PI)*(2f/3f))];
immutable double spokeWidth = 256, spokeLenght = 1024-128;
immutable double spokesBaseHeight = 30;
immutable HowToHandleNewHeight spokesHieghtHandaling = HowToHandleNewHeight.OVER_WRITE_IF_HIGHER_THAN_PERVIOUS;
immutable int spokesPriority = 2;



public void createThreeWay(){
	HeightMapGenerator generator = HeightMapGenerator(mapSize, mapSize, mapDefaultHeight);
	
	makeCenter(generator);
	makeSpokes(generator);
	
	generator.genHeightMap();
	
	saveHeightMap("ThreeWay.raw", generator.map);
	
}

private void makeCenter(ref HeightMapGenerator generator){
	HeightValue returnValue;
	returnValue.howToHandleNewHeight = centerCircleHeightHandling;
	returnValue.priority = centerCirclePriority;
	
	HeightFeatureCircle centerCircle = new HeightFeatureCircle(
		mapCenter,
		centerCircleRadius,
		&distanceToHeight_Hill!(
			centerCircleRadius,
			centerCircleSlope,
			centerCircleMinHeight,
			centerCirleMaxHieght
		),
		returnValue
	);
	
	generator.addFeature(centerCircle);
	
}

private void makeSpokes(ref HeightMapGenerator generator){
	Point topLeft = Point(0,0);
	Point topRight = Point(spokeWidth, 0);
	Point bottomLeft = Point(0, spokeLenght);
	Point bottomRight = Point(spokeWidth, spokeLenght);
	HeightValue returnValue;
	returnValue.howToHandleNewHeight = spokesHieghtHandaling;
	returnValue.priority = spokesPriority;
	
	HeightFeatureTriangle topLeftTriangle = new HeightFeatureTriangle(
		topLeft,
		topRight,
		bottomLeft,
		spokesBaseHeight,
		spokesBaseHeight,
		spokesBaseHeight,
		returnValue
	);
	
	HeightFeatureTriangle bottomRightTriangle = new HeightFeatureTriangle(
		bottomRight,
		topRight,
		bottomLeft,
		spokesBaseHeight,
		spokesBaseHeight,
		spokesBaseHeight,
		returnValue
	);
	
	topLeftTriangle.translateFeature(mapCenter.x-(spokeWidth/2), mapCenter.y-spokeLenght);
	bottomRightTriangle.translateFeature(mapCenter.x-(spokeWidth/2), mapCenter.y-spokeLenght);
	
	foreach(double rotation; spokeRotations){
		HeightFeature topLeftTriangleCopy = topLeftTriangle.copy();
		HeightFeature bottomRightTriangleCopy = bottomRightTriangle.copy();
		topLeftTriangleCopy.rotateAroundPointOnMap(mapCenter, rotation);
		bottomRightTriangleCopy.rotateAroundPointOnMap(mapCenter, rotation);
		generator.addFeature(topLeftTriangleCopy);
		generator.addFeature(bottomRightTriangleCopy);
		
	}
	
	
	
	
	
	
}








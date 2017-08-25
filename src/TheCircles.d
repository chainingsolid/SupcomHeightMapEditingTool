
import NewHeightMapGenSystem;
import app;
import std.math;
import std.algorithm.comparison;
import std.stdio;

immutable int maxNumberOfPlayers = 12;

immutable int mapSize = 2049;
double numberOfRidges = 6;
//main circle
immutable double radiusOfMainCircle = (2049/2)-(128*2);
double baseHeightOfMainCircle = 100;
double seaFloorHeight = 60;
//pass circles
double passCircleRadius = 16;
immutable int numberOfPassesPerRidge = maxNumberOfPlayers;
//outerIslands
immutable int numberOfOuterIslands = maxNumberOfPlayers;
immutable double radiusOfTheIslands = 120;
double percentOfIslandRadiusThatsLand = 0.45;
double islandsDistanceFromTheCenter = radiusOfMainCircle + (radiusOfTheIslands)+8;

public void genTheCircles(){
	
	
	HeightMapGenerator mapGenerator = HeightMapGenerator(mapSize, mapSize, seaFloorHeight);
	
	addMainCircleToGenList(mapGenerator);
	
	addPassCircles(mapGenerator);
	
	addOuterIslands(mapGenerator);
	
	mapGenerator.genHeightMap();
	
	saveHeightMap("theCircles.raw", mapGenerator.map);
	
}

public void addMainCircleToGenList(ref HeightMapGenerator mapGenerator){
	Point centerOfMainCircle = Point(mapSize/2, mapSize/2);
	HeightValue heightValueReturnSettings = HeightValue();
	heightValueReturnSettings.height = baseHeightOfMainCircle;//doesn't actaly matter
	heightValueReturnSettings.priority = 2;
	heightValueReturnSettings.howToHandleNewHeight = HowToHandleNewHeight.OVER_WRITE_PREVIOUS_VALUE;
	
	HeightFeatureCircle mainCircle = new HeightFeatureCircle(
		centerOfMainCircle,
		radiusOfMainCircle,
		&radiusOfMainCircleToHeight,
		heightValueReturnSettings
	);
	
	mapGenerator.addFeature(mainCircle);
	
}

public double radiusOfMainCircleToHeight(double radius){
	double reminderBy = radiusOfMainCircle/numberOfRidges;
	double remainder = radius % reminderBy;
	remainder = min(remainder, reminderBy-remainder);
	double widthOfRidge = 8;
	if(remainder < widthOfRidge && (radius/reminderBy) < (numberOfRidges-0.5) && radius > (reminderBy/2)){
		double weightPeakOfRidge = (widthOfRidge-remainder);
		double weightBaseOfRidge = widthOfRidge-(widthOfRidge-remainder);
		double ridgePeakHeight = baseHeightOfMainCircle+15;
		return ((
				(ridgePeakHeight*weightPeakOfRidge)+
				(baseHeightOfMainCircle*weightBaseOfRidge)
			)/(weightBaseOfRidge+weightPeakOfRidge));
	}else{
		double distanceToEdgeOfCircle = radiusOfMainCircle - radius;
		if((distanceToEdgeOfCircle) < reminderBy/2){
			double distanceToHalfWayToLastRidge = radius - (radiusOfMainCircle-(reminderBy/2));
			return (
						(seaFloorHeight*distanceToHalfWayToLastRidge)+
						(baseHeightOfMainCircle*distanceToEdgeOfCircle)
					)/
					(distanceToHalfWayToLastRidge+distanceToEdgeOfCircle);
		}
		
	}
	
	return baseHeightOfMainCircle;
}

public void addPassCircles(ref HeightMapGenerator mapGenerator){
	Point centerOfTemplateCircle = Point(mapSize/2, mapSize/2);
	
	HeightValue heightValueReturnSettings = HeightValue();
	heightValueReturnSettings.height = baseHeightOfMainCircle;//doesn't actaly matter
	heightValueReturnSettings.priority = 3;
	heightValueReturnSettings.howToHandleNewHeight = HowToHandleNewHeight.OVER_WRITE_PREVIOUS_VALUE;
	
	
	HeightFeatureCircle templatePassCircle = new HeightFeatureCircle(
		centerOfTemplateCircle,
		passCircleRadius,
		&radiusOfPassCircleToHeight,
		heightValueReturnSettings
	);
	
	double distanceBetweenRidges = radiusOfMainCircle/numberOfRidges;
	double radiansBetweenPasses = (PI*2)/numberOfPassesPerRidge;
	
	for(int ridge = 1; ridge < numberOfRidges; ridge++){
		double radOffSet = 0;
		if(ridge % 2 == 0){
			radOffSet = radiansBetweenPasses/2;
		}
		
		for(double rad = 0; rad < PI*2; rad += radiansBetweenPasses){
			HeightFeature passCircle = templatePassCircle.copy();
			passCircle.translateFeature(cos(rad+radOffSet)*ridge*distanceBetweenRidges, sin(rad+radOffSet)*ridge*distanceBetweenRidges);
			mapGenerator.addFeature(passCircle);
		}
	}
	
}

public double radiusOfPassCircleToHeight(double radius){
	return baseHeightOfMainCircle;
}


public void addOuterIslands(ref HeightMapGenerator mapGenerator){
	Point centerOfTemplateCircle = Point(mapSize/2, mapSize/2);
	
	HeightValue heightValueReturnSettings = HeightValue();
	heightValueReturnSettings.height = baseHeightOfMainCircle;//doesn't actaly matter
	heightValueReturnSettings.priority = 3;
	heightValueReturnSettings.howToHandleNewHeight = HowToHandleNewHeight.OVER_WRITE_IF_HIGHER_THAN_PERVIOUS;
	
	
	HeightFeatureCircle islandTemplate = new HeightFeatureCircle(
		centerOfTemplateCircle,
		radiusOfTheIslands,
		&islandRadiusToHeight,
		heightValueReturnSettings
	);
	
	double radiansBetweenIslands = (PI*2)/numberOfOuterIslands;
	for(double rad = 0; rad < PI*2; rad += radiansBetweenIslands){
		HeightFeature island = islandTemplate.copy();
		island.translateFeature(cos(rad)*islandsDistanceFromTheCenter, sin(rad)*islandsDistanceFromTheCenter);
		mapGenerator.addFeature(island);
	}
	
}

public double islandRadiusToHeight(double radius){
	double outerPartOfTheIslandRadius = radiusOfTheIslands*percentOfIslandRadiusThatsLand;
	if(radius > outerPartOfTheIslandRadius){
		double baseHeightWeight = (radiusOfTheIslands-radius);
		double seaFloorHeightWeight = (radius - outerPartOfTheIslandRadius);
		return ((baseHeightOfMainCircle*baseHeightWeight)+
				(seaFloorHeight*seaFloorHeightWeight))/
				(baseHeightWeight+seaFloorHeightWeight);
	}else{
		return baseHeightOfMainCircle;
	}
}






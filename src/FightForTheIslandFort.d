import app;
import NewHeightMapGenSystem;




immutable int mapSize = 2049;
immutable int mapCenter = mapSize/2;
immutable int centerIslandSize = 1024, halfCenterIslandSize = centerIslandSize/2;
immutable double baseMapHeight = 64;
immutable double centerIslandHeight = baseMapHeight + 32;

immutable Point 
	mapCenterPoint = Point(mapCenter, mapCenter),
	islandTopLeft = Point(mapCenter-halfCenterIslandSize, mapCenter-halfCenterIslandSize),
	islandTopRight = Point(mapCenter+halfCenterIslandSize, mapCenter-halfCenterIslandSize),
	islandBottomLeft = Point(mapCenter-halfCenterIslandSize, mapCenter+halfCenterIslandSize),
	islandBottomRight = Point(mapCenter+halfCenterIslandSize, mapCenter+halfCenterIslandSize)
	;




HeightMapGenerator islandFortHeightMapGenerator;


public void genFightForTheIslandFort(){
	
	islandFortHeightMapGenerator = HeightMapGenerator(mapSize, mapSize, baseMapHeight);
	
	HeightValue centerIslandReturnSettings;
	centerIslandReturnSettings.howToHandleNewHeight = HowToHandleNewHeight.OVER_WRITE_IF_HIGHER_THAN_PERVIOUS;
	centerIslandReturnSettings.priority = 0;
	
	HeightFeatureTriangle centerIslandTopLeft = new HeightFeatureTriangle(
																	islandTopLeft, islandTopRight, islandBottomLeft, 
																	centerIslandHeight, centerIslandHeight, centerIslandHeight,
																	centerIslandReturnSettings);
	
	HeightFeatureTriangle centerIslandBottomRight = new HeightFeatureTriangle(
																	islandBottomLeft, islandTopRight, islandBottomRight, 
																	centerIslandHeight, centerIslandHeight, centerIslandHeight,
																	centerIslandReturnSettings);
	
	islandFortHeightMapGenerator.addFeature(centerIslandTopLeft);
	islandFortHeightMapGenerator.addFeature(centerIslandBottomRight);
	
	islandFortHeightMapGenerator.genHeightMap();
	
	saveHeightMap("fightForTheIslandFort.raw", islandFortHeightMapGenerator.map);
	
}






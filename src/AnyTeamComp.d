import app;
import std.math;

int mapSize = 1025;
immutable int mapCenterCord = 1025/2;
Point mapCenter = Point(mapCenterCord, mapCenterCord);
float mapBaseHeight = 15;

double[] spokeRotations = [
	(PI*2)*(1f/16f),
	(PI*2)*(2f/16f),
	(PI*2)*(3f/16f),
	(PI*2)*(4f/16f),
	(PI*2)*(5f/16f),
	(PI*2)*(6f/16f),
	(PI*2)*(7f/16f),
	(PI*2)*(8f/16f),
	(PI*2)*(9f/16f),
	(PI*2)*(10f/16f),
	(PI*2)*(11f/16f),
	(PI*2)*(12f/16f),
	(PI*2)*(13f/16f),
	(PI*2)*(14f/16f),
	(PI*2)*(15f/16f),
	];

//spokeInfo
int spokeDistanceFromCenter = 256+128, spokeDistanceFromEdge = 64;
int spokeWidth = 32;
int spokeSlopeWidth = 32;
float spokeBaseHieght = 30;

//CenterAreaInfo
int centerAreaSize = 128+64;
float lowerCenterAreaHeight = 20;

//Base Info
int baseAreaDistanceFromCenter = 256;
int distanceFromSpokeCenter = 128;
int baseAreaSize = 32;
float baseAreaHeight = 30.5f;





public void createAnyTeamComp(){
	map = makeHieghtMap(mapSize, mapSize, cleanHeightToRawShortValue(mapBaseHeight));
	createSpokes();
	//createCenter();
	//createBaseAreas();
	
	
	saveHeightMap("AnyTeamComp.raw", map);
}

private void createSpokes(){
	
	Point topEdgeSidePoint = Point(spokeDistanceFromEdge, mapCenterCord-(spokeWidth/2));
	Point bottomEdgeSidePoint = Point(spokeDistanceFromEdge, mapCenterCord+(spokeWidth/2));
	Point topCenterSidePoint = Point(mapCenterCord-spokeDistanceFromCenter, mapCenterCord-(spokeWidth/2));
	Point bottomCenterSidePoint = Point(mapCenterCord-spokeDistanceFromCenter, mapCenterCord+(spokeWidth/2));
	//bottom/edge
	putTriangleOnMapRotated(topEdgeSidePoint, spokeBaseHieght, bottomCenterSidePoint, spokeBaseHieght, bottomEdgeSidePoint, spokeBaseHieght, mapCenter, spokeRotations);
	//top/center
	putTriangleOnMapRotated(topEdgeSidePoint, spokeBaseHieght, bottomCenterSidePoint, spokeBaseHieght, topCenterSidePoint, spokeBaseHieght, mapCenter, spokeRotations);
	
	
	Point slopeTopEdgeSidePoint = Point(topEdgeSidePoint.x-spokeSlopeWidth, topEdgeSidePoint.y-spokeSlopeWidth);
	Point slopeBottomEdgeSidePoint = Point(bottomEdgeSidePoint.x-spokeSlopeWidth, bottomEdgeSidePoint.y+spokeSlopeWidth);
	Point slopeTopCenterSidePoint = Point(topCenterSidePoint.x+spokeSlopeWidth, topCenterSidePoint.y-spokeSlopeWidth);
	Point slopeBottomCenterSidePoint = Point(bottomCenterSidePoint.x+spokeSlopeWidth, bottomCenterSidePoint.y+spokeSlopeWidth);
	//slopes/edge
	putTriangleOnMapRotated(topEdgeSidePoint, spokeBaseHieght, slopeTopEdgeSidePoint, mapBaseHeight, bottomEdgeSidePoint, spokeBaseHieght, mapCenter, spokeRotations);
	putTriangleOnMapRotated(slopeTopEdgeSidePoint, mapBaseHeight, slopeBottomEdgeSidePoint, mapBaseHeight, bottomEdgeSidePoint, spokeBaseHieght, mapCenter, spokeRotations);
	
	putTriangleOnMapRotated(slopeTopEdgeSidePoint, mapBaseHeight, topEdgeSidePoint, spokeBaseHieght, topCenterSidePoint, spokeBaseHieght, mapCenter, spokeRotations);
	putTriangleOnMapRotated(slopeBottomEdgeSidePoint, mapBaseHeight, bottomEdgeSidePoint, spokeBaseHieght, bottomCenterSidePoint, spokeBaseHieght, mapCenter, spokeRotations);
	putTriangleOnMapRotated(slopeTopEdgeSidePoint, mapBaseHeight, topCenterSidePoint, spokeBaseHieght, slopeTopCenterSidePoint, mapBaseHeight, mapCenter, spokeRotations);
	putTriangleOnMapRotated(slopeBottomEdgeSidePoint, mapBaseHeight, bottomCenterSidePoint, spokeBaseHieght, slopeBottomCenterSidePoint, mapBaseHeight, mapCenter, spokeRotations);
	
}

private void createCenter(){
	
	Point centerTriangleEdge = Point(mapCenterCord-centerAreaSize, mapCenterCord);
	Point centerTriangleEdgeRotated = rotateCord(centerTriangleEdge, mapCenter, (PI*2)*(1f/8f));
	putTriangleOnMapRotated(mapCenter, spokeBaseHieght, centerTriangleEdge, spokeBaseHieght, centerTriangleEdgeRotated, spokeBaseHieght, mapCenter, spokeRotations);
	
}

private void createBaseAreas(){
	Point topLeft = Point(mapCenterCord-baseAreaDistanceFromCenter-(baseAreaSize/2), mapCenterCord-(spokeWidth/2)-(baseAreaSize/2));
	Point topRight = Point(mapCenterCord-baseAreaDistanceFromCenter+(baseAreaSize/2), mapCenterCord-(spokeWidth/2)-(baseAreaSize/2));
	Point bottomLeft = Point(mapCenterCord-baseAreaDistanceFromCenter-(baseAreaSize/2), mapCenterCord-(spokeWidth/2)+(baseAreaSize/2));
	Point bottomRight = Point(mapCenterCord-baseAreaDistanceFromCenter+(baseAreaSize/2), mapCenterCord-(spokeWidth/2)+(baseAreaSize/2));
	
	putTriangleOnMapRotated(topLeft, baseAreaHeight, topRight, baseAreaHeight, bottomLeft, baseAreaHeight, mapCenter, spokeRotations);
	putTriangleOnMapRotated(bottomLeft, baseAreaHeight, bottomRight, baseAreaHeight, topRight, baseAreaHeight, mapCenter, spokeRotations);
	
	topLeft.y += spokeWidth;
	topRight.y += spokeWidth;
	bottomLeft.y += spokeWidth;
	bottomRight.y += spokeWidth;
	
	putTriangleOnMapRotated(topLeft, baseAreaHeight, topRight, baseAreaHeight, bottomLeft, baseAreaHeight, mapCenter, spokeRotations);
	putTriangleOnMapRotated(bottomLeft, baseAreaHeight, bottomRight, baseAreaHeight, topRight, baseAreaHeight, mapCenter, spokeRotations);
	
}







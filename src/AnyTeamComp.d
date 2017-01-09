import app;
import std.math;

int mapSize = 2049;
int mapCenterCord = 2049/2;
float mapBaseHeight = 10;

double[] spokeRotations = [
/*	(PI*2)*(1f/8f),
	(PI*2)*(2f/8f),
	(PI*2)*(3f/8f),
	(PI*2)*(4f/8f),
	(PI*2)*(5f/8f),
	(PI*2)*(6f/8f),
	(PI*2)*(7f/8f) */
	];


int spokeDistanceFromCenter = 64, spokeDistanceFromEdge = 128;
int spokeWidth = 128;
int spokeSlopeWidth = 64;
float spokeBaseHieght = 30;


HeightMap map;
public void createAnyTeamComp(){
	map = makeHieghtMap(mapSize, mapSize, cleanHeightToRawShortValue(mapBaseHeight));
	createSpokes();
	
	
	
	saveHeightMap("AnyTeamComp.raw", map);
}

private void createSpokes(){
	
	Point topEdgeSidePoint = [spokeDistanceFromEdge, mapCenterCord-(spokeWidth/2)];
	Point bottomEdgeSidePoint = [spokeDistanceFromEdge, mapCenterCord+(spokeWidth/2)];
	Point topCenterSidePoint = [ mapCenterCord-spokeDistanceFromCenter, mapCenterCord-(spokeWidth/2)];
	Point bottomCenterSidePoint = [mapCenterCord-spokeDistanceFromCenter, mapCenterCord+(spokeWidth/2)];
	//bottom/edge
	putTriangleOnMapRotated(topEdgeSidePoint, spokeBaseHieght, bottomCenterSidePoint, spokeBaseHieght, bottomEdgeSidePoint, spokeBaseHieght, [mapCenterCord, mapCenterCord], spokeRotations);
	//top/center
	putTriangleOnMapRotated(topEdgeSidePoint, spokeBaseHieght, bottomCenterSidePoint, spokeBaseHieght, topCenterSidePoint, spokeBaseHieght, [mapCenterCord, mapCenterCord], spokeRotations);
	
	
	Point slopeTopEdgeSidePoint = [topEdgeSidePoint[0]-spokeSlopeWidth, topEdgeSidePoint[1]-spokeSlopeWidth];
	Point slopeBottomEdgeSidePoint = [bottomEdgeSidePoint[0]-spokeSlopeWidth, bottomEdgeSidePoint[1]+spokeSlopeWidth];
	Point slopeTopCenterSidePoint = [topCenterSidePoint[0]+spokeSlopeWidth, topCenterSidePoint[1]-spokeSlopeWidth];
	Point slopeBottomCenterSidePoint = [bottomCenterSidePoint[0]+spokeSlopeWidth, bottomCenterSidePoint[1]+spokeSlopeWidth];
	//slopes
	putTriangleOnMapRotated(topEdgeSidePoint, spokeBaseHieght, slopeTopEdgeSidePoint, mapBaseHeight, bottomEdgeSidePoint, spokeBaseHieght, [mapCenterCord, mapCenterCord], spokeRotations);
	
	
	
	
}











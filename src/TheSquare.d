import app;
import std.math;

immutable int mapSize = 2049;
double mapCenter = cast(float)(mapSize/2);
int widthOfOuterLandRing = 150;
int widhtOfWaterRing = 300;


void genTheSquare(){
	map = makeHieghtMap(mapSize, mapSize, cleanHeightToRawShortValue(60));
	
	
	genTheWater();
	
	
	
	
	
	
	
	saveHeightMap("TheSquare.raw", map);
}

void genTheWater(){
	
	float levelMinValue = cast(float)widthOfOuterLandRing;
	float levelMaxValue = cast(float)(widhtOfWaterRing);
	
	for(int level = widthOfOuterLandRing; (level - widthOfOuterLandRing) < widhtOfWaterRing; level++){
		for(int x = 0; x < mapSize - (level*2); x++){
			//TODO figure out how to do the depth on the water
			setHieghtRotated(map, cleanHeightToRawShortValue(0), level+x, level, mapCenter, mapCenter, [(PI*2)*(1f/4f),(PI*2)*(2f/4f),(PI*2)*(3f/4f),(PI*2)*(4f/4f)]);
		}
	}
	
	
}








import app;
import std.math;
import std.typecons;
import std.stdio;

float centerCord = 2049/2;
double[] mirrorRotation = [PI];

int[2][] midIslandPositions;
int midIslandSize = 128;
int midIslandSpacing = 256;

float cornerIslandFrontAreaBaseHeigth = 30;

int frontHillsForwardDistance = 1024-128;
int frontHillsSize = 64;
float frontHillBaseHeight = 30.5f;
float frontHillShieldRadius = 50;
float frontHillShieldThickness = 5;
int frontHillShieldHeight = 5;
float frontShieldStartRad = PI+PI_2+PI_2, frontShieldEndRad = (PI*2)+PI_2;


float cornerIslandBackAreaBaseHeight = 40;

float backHillsBaseHeight = 50;
int backHillsSize = 64;
int backHillRampSize = 8;
int backHillsFormationCenter = 128+64;
float backHillsFormationRadius = 128;

public void createTheOceanHieghtMap(){
	HeightMap map = makeHieghtMap(2049, 2049, cleanHeightToRawShortValue(10));
	createCornerIslandsBase(map);
	createCornerIslandBackHills(map);
	createCornerIslandFrontHills(map);
	
	
	createMidIslands(map);
	
	
	
	saveHeightMap("theOceanHieghtMap.raw", map);
}

private void createCornerIslandsBase(HeightMap map){
	float terrainHeight = 10;
	for(int diagnalLineNum = 1024; diagnalLineNum > 0; diagnalLineNum--){
		for(int i = 0; i < diagnalLineNum; i++){
			setHieghtRotated(map, cleanHeightToRawShortValue(terrainHeight), i, diagnalLineNum-i, centerCord, centerCord, mirrorRotation);
		}
		if(terrainHeight < cornerIslandFrontAreaBaseHeigth){
			terrainHeight += .5;
		}
	}
	terrainHeight = cornerIslandFrontAreaBaseHeigth;
	for(int diagnalLineNum = 1024-128*2; diagnalLineNum > 0; diagnalLineNum--){
		for(int i = 0; i < diagnalLineNum; i++){
			if(terrainHeight < cornerIslandBackAreaBaseHeight){
				float iAsFloat = cast(float)i;
				float percent = (cos(8*(iAsFloat/(cast(float)diagnalLineNum))*(2*PI)-PI)+1)/2;
				setHieghtRotated(map, cleanHeightToRawShortValue((percent*(terrainHeight)+((1-percent)*cornerIslandBackAreaBaseHeight))), i, diagnalLineNum-i, centerCord, centerCord, mirrorRotation);
			}else{
				setHieghtRotated(map, cleanHeightToRawShortValue(cornerIslandBackAreaBaseHeight), i, diagnalLineNum-i, centerCord, centerCord, mirrorRotation);
			}
		}
		
		if(terrainHeight < cornerIslandBackAreaBaseHeight){
			terrainHeight += .25;
		}
	}
	
	
	
}

private void createCornerIslandFrontHills(HeightMap map){
	
	int diagnalLineNum = frontHillsForwardDistance;
	for(float percent = 1f/16f; percent <= 1f; percent += 1f/8f){
		int centerOfHillX = cast(int)((cast(float)diagnalLineNum)*percent);
		int centerOfHillY = cast(int)((cast(float)diagnalLineNum) - (cast(float)diagnalLineNum)*percent);
		for(int x = -frontHillsSize/2; x < frontHillsSize/2; x++){
			for(int y = -frontHillsSize/2; y < frontHillsSize/2; y++){
				setHieghtRotated(map, cleanHeightToRawShortValue(frontHillBaseHeight), centerOfHillX+x, centerOfHillY+y, centerCord, centerCord, mirrorRotation);
			}
		}
		for(float rad = frontShieldStartRad; rad < frontShieldEndRad; rad += .001f){
			for(float thickness = 0; thickness < frontHillShieldThickness; thickness++){
				int x = cast(int)(centerOfHillX+round(cos(rad)*(frontHillShieldRadius+thickness)));
				int y = cast(int)(centerOfHillY+round(sin(rad)*(frontHillShieldRadius+thickness)));
				setHieghtRotated(map, cleanHeightToRawShortValue(frontHillBaseHeight+frontHillShieldHeight), x, y, centerCord, centerCord, mirrorRotation);
			}
		}
	}
	
	
	/*
	for(int diagnalDistance = 0; diagnalDistance < 128*3; diagnalDistance += 128){
		for(int w = -frontHillsSize/2; w < frontHillsSize/2; w++){
			for(int h = -frontHillsSize/2; h < frontHillsSize/2; h++){
				setHieghtRotated(map, cleanHeightToRawShortValue(frontHillBaseHeight), frontHillsForwardDistance+diagnalDistance+w, frontHillsForwardDistance-diagnalDistance+h, centerCord, centerCord, PI);
				setHieghtRotated(map, cleanHeightToRawShortValue(frontHillBaseHeight), frontHillsForwardDistance-diagnalDistance+w, frontHillsForwardDistance+diagnalDistance+h, centerCord, centerCord, PI);
			}
		}
		
	}
	*/
}

private void createCornerIslandBackHills(HeightMap map){
	for(float rad = 0; rad < 2*PI; rad += (2*PI)/8){
		int hillCenterX = backHillsFormationCenter + cast(int)round(cos(rad)*backHillsFormationRadius);
		int hillCenterY = backHillsFormationCenter + cast(int)round(sin(rad)*backHillsFormationRadius);
		for(int x = -backHillsSize/2; x < backHillsSize/2; x++){
			for(int y = -backHillsSize/2; y < backHillsSize/2; y++){
				setHieghtRotated(map, cleanHeightToRawShortValue(backHillsBaseHeight), x+hillCenterX, y+hillCenterY, centerCord, centerCord, mirrorRotation);
			}
		}
		float rampHieght = cornerIslandBackAreaBaseHeight;
		for(int x = -backHillsSize/2; x < backHillsSize/2; x++){
			for(int y = -backHillsSize/2; y < (-backHillsSize/2)+backHillRampSize; y++){
				setHieghtRotated(map, cleanHeightToRawShortValue(rampHieght), x+hillCenterX, y+hillCenterY, centerCord, centerCord, mirrorRotation);
				setHieghtRotated(map, cleanHeightToRawShortValue(rampHieght), y+hillCenterX, x+hillCenterY, centerCord, centerCord, mirrorRotation);
			}
			if(((-backHillsSize/2)+backHillRampSize)-2 < x && x < ((backHillsSize/2)-backHillRampSize)-1){
				rampHieght += ((backHillsBaseHeight-cornerIslandBackAreaBaseHeight))/(cast(float)(backHillsSize-(backHillRampSize*2)));
			}
		}
		
	}
	
	
}

private void createMidIslands(HeightMap map){
	
	for(int diagnalDistance = 512+midIslandSpacing; diagnalDistance <= 2049/2; diagnalDistance += midIslandSpacing){
		for(int sideDiagnalDistance = 0; sideDiagnalDistance < midIslandSpacing*(diagnalDistance/midIslandSpacing); sideDiagnalDistance += midIslandSpacing){
			midIslandPositions ~= [diagnalDistance - sideDiagnalDistance, diagnalDistance + sideDiagnalDistance];
			midIslandPositions ~= [diagnalDistance + sideDiagnalDistance, diagnalDistance - sideDiagnalDistance];
		}
	}
	
	foreach(int[2] islandLocation; midIslandPositions){
		int run = 0;
		for(float height = 10; height <= 30; height += .5){
			for(int w = run; w < (midIslandSize-run); w++){
				for(int h = run; h < (midIslandSize-run); h++){
					setHieghtRotated(map, cleanHeightToRawShortValue(height), (islandLocation[0]-midIslandSize/2)+w, (islandLocation[1]-midIslandSize/2)+h, centerCord, centerCord, mirrorRotation);
				}
			}
			run++;
		}
	}
}



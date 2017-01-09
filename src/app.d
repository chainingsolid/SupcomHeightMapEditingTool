import std.stdio;
import std.file;
import std.math;
import std.typecons;

import TheOcean;
import AnyTeamComp;
import Test;
alias HeightMap = ushort[][];

alias Point = float[2];

/**
	Put map[h][w] on purpose int the save and load funcs instead of 
	
**/


void main() {
	createAnyTeamComp();
	
	
}





public ushort cleanHeightToRawShortValue(double cleanValue, double maxHeight = 128){
	return cast(ushort)round(cleanValue *((cast(double)ushort.max)/maxHeight));
}

public double getRadFromCords(double x, double y){
	return atan2(y, x);
}

public double getDistance(double x1, double y1, double x2, double y2){
	return sqrt(((x1-x2)*(x1-x2)) + ((y1-y2)*(y1-y2)));
}

public Point rotateCord(double x, double y, double aroundX, double aroundY, double radians){
	double distance = getDistance(x, y, aroundX, aroundY);
	double rad = getRadFromCords(x-aroundX, y-aroundY);
	rad += radians;
	return [aroundX+(cos(rad)*distance), aroundY+(sin(rad)*distance)];
}

public Point rotateCord(Point point, Point around, double radians){
	return rotateCord(point[0], point[1], around[0], around[1], radians);
}

public void setHieghtRotated(HeightMap map, ushort hieghtValue, int w, int h, double rotationPointX, double rotationPointY, double[] radians){
	logIfCordsOutOfBounds(map, w, h);
	map[w][h] = hieghtValue;
	for(int index = 0; index < radians.length; index++){
		Tuple!(double, double) roatatedCord = rotateCord(cast(double)w, cast(double)h, rotationPointX, rotationPointY, radians[index]);
		int x = cast(int)round(roatatedCord[0]);
		int y = cast(int)round(roatatedCord[1]);
		logIfCordsOutOfBounds(map, x, y);
		map[x][y] = hieghtValue;
	}
}

public bool areCordsInBounds(HeightMap map, int w, int h){
	if(w < 0 || w > map.length){
		return false;
	}
	if(h < 0 || h > map[0].length){
		return false;
	}
	return true;
}

public bool logIfCordsOutOfBounds(HeightMap map, int w, int h){
	bool b = areCordsInBounds(map, w, h);
	if(!b){
		writefln("Cords %d, %d are out of bounds", w, h);
	}
	return b;
}

//file stuffs

public HeightMap makeHieghtMap(int width, int height, ushort defaultHeight){
	HeightMap map;
	map.length = width;
	for(int i = 0; i < map.length; i++){
		map[i].length = height;
	}
	for(int w = 0; w < map.length; w++){
		for(int h = 0; h < map[0].length; h++){
			map[w][h] = defaultHeight;
		}
	}
	
	return map;
}

public HeightMap loadHeightMap(string fileName, int width, int height){
	HeightMap hMap = makeHieghtMap(width, height, 10);
	void[] rawData = read(fileName, 2*(width*height));
	ushort[] data = cast(ushort[])rawData;
	int indexInRawFileData = 0;
	for(int w = 0; w < width; w++){
		for(int h = 0; h < height; h++){
			hMap[h][w] = data[indexInRawFileData];
			indexInRawFileData++;
		}
	}
	return hMap;
}

public void saveHeightMap(string fileName, HeightMap map){
	int width = map.length;
	int height = map[0].length;
	ushort[] data;
	data.length = (width*height);
	int indexInDataArray = 0;
	for(int w = 0; w < width; w++){
		for(int h = 0; h < height; h++){
			data[indexInDataArray] = map[h][w];
			indexInDataArray++;
		}
	}
	std.file.write(fileName, data);
	writefln("saved %s!", fileName);
}

public struct PointInTriangleCheck{
	
	Point a, b, c;
	Line ab, ac, bc;
	float abDirection, acDirection, bcDirection;
	
	this(Point a, Point b, Point c){
		this.a = a;
		this.b = b;
		this.c = c;
		ab = Line(a, b);
		ac = Line(a, c);
		bc = Line(b, c);
		if(ab.func(c[0]) < c[1]){
			abDirection = 1;
		}else{
			abDirection = -1;
		}
		if(ac.func(b[0]) < b[1]){
			acDirection = 1;
		}else{
			acDirection = -1;
		}
		if(bc.func(a[0]) < a[1]){
			bcDirection = 1;
		}else{
			bcDirection = -1;
		}
	}
	
	public bool isPointInTriangle(Point p){
		if((p[1] - ab.func(p[0]))*abDirection < 0){
			return false;
		}
		if((p[1] - ac.func(p[0]))*acDirection < 0){
			return false;
		}
		if((p[1] - bc.func(p[0]))*bcDirection < 0){
			return false;
		}
		return true;
	}
	
}

public struct Line{
	
	float slope, yIntercept;
	
	this(Point a, Point b){
		slope = (a[1]-b[1])/(a[0]-b[0]);
		yIntercept = -1*slope*a[0]+a[1];
	}
	
	public float func(float x){
		return slope*x+yIntercept;
	}
	
}

public struct HeightMapTriangle{
	
	float heightA, heightB, heightC;
	
	PointInTriangleCheck check;
	
	this(Point pointA, float heightA, Point pointB, float heightB, Point pointC, float heightC){
		check = PointInTriangleCheck(pointA, pointB, pointC);
		this.heightA = heightA;
		this.heightB = heightB;
		this.heightC = heightC;
	}
	
	public void putTriangleOnMap(HeightMap map){
		for(int x = cast(int)floor(minNumber([check.a[0], check.b[0], check.c[0]])); x < ceil(maxNumber([check.a[0], check.b[0], check.c[0]])); x++){
			for(int y = cast(int)floor(minNumber([check.a[1], check.b[1], check.c[1]])); y < ceil(maxNumber([check.a[1], check.b[1], check.c[1]])); y++){
				if(check.isPointInTriangle([x, y])){
					float distA = getDistance(x, y, check.a[0], check.a[1]);
					float distB = getDistance(x, y, check.b[0], check.b[1]);
					float distC = getDistance(x, y, check.c[0], check.c[1]);
					float percentA = distA/(distA+distB+distC);
					float percentB = distB/(distA+distB+distC);
					float percentC = distC/(distA+distB+distC);
					
					float height = (percentA*heightA) + (percentB*heightB) + (percentC*heightC);
					map[x][y] = cleanHeightToRawShortValue(height);
				}
			}
		}
	}
}

public void putTriangleOnMapRotated(Point pointA, float heightA, Point pointB, float heightB, Point pointC, float heightC, Point around, double[] radians){
	HeightMapTriangle triangle = HeightMapTriangle(pointA, heightA, pointB, heightB, pointC, heightC);
	triangle.putTriangleOnMap(map);
	for(int i = 0; i < radians.length; i++){
		triangle = HeightMapTriangle(
			rotateCord(pointA, around, radians[i]), heightA,
			rotateCord(pointB, around, radians[i]), heightB,
			rotateCord(pointC, around, radians[i]), heightC,
		);
		triangle.putTriangleOnMap(map);
	}
}




public float minNumber(float[] f){
	float min = f[0];
	int i = 1;
	while(i < f.length){
		if(f[i] < min){
			min = f[i];
		}
		i++;
	}
	return min;
}

public float maxNumber(float[] f){
	float max = f[0];
	int i = 1;
	while(i < f.length){
		if(f[i] > max){
			max = f[i];
		}
		i++;
	}
	return max;
}





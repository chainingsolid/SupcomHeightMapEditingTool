import std.stdio;
import std.file;
import std.math;
import std.typecons;
import std.conv;

import TheCircles;


import NewHeightMapGenSystem;
alias HeightMap = ushort[][];

struct Point{
	
	double x, y;
	
	this(double x, double y){
		this.x = x;
		this.y = y;
	}
	
	public void roundPointToNearestIntergerLocation(){
		x = round(x);
		y = round(y);
	}
	
}


/**
	Put map[h][w] on purpose in the save and load funcs instead of 
	
**/


///GeneralMap Variable
HeightMap map;

void main() {
	
	genTheCircles();
	
	
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

public double getDistance(Point p1, Point p2){
	return getDistance(p1.x, p1.y, p2.x, p2.y);
}

public Point rotateCord(double x, double y, double aroundX, double aroundY, double radians){
	double distance = getDistance(x, y, aroundX, aroundY);
	double rad = getRadFromCords(x-aroundX, y-aroundY);
	rad += radians;
	return Point(aroundX+(cos(rad)*distance), aroundY+(sin(rad)*distance));
}

public Point rotateCord(Point point, Point around, double radians){
	return rotateCord(point.x, point.y, around.x, around.y, radians);
}

public void setHieghtRotated(HeightMap map, ushort hieghtValue, int w, int h, double rotationPointX, double rotationPointY, double[] radians){
	logIfCordsOutOfBounds(map, w, h);
	map[w][h] = hieghtValue;
	for(int index = 0; index < radians.length; index++){
		Point roatatedCord = rotateCord(Point(cast(double)w, cast(double)h), Point(rotationPointX, rotationPointY), radians[index]);
		int x = cast(int)round(roatatedCord.x);
		int y = cast(int)round(roatatedCord.y);
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
	double abDirection, acDirection, bcDirection;
	
	this(Point a, Point b, Point c){
		this.a = a;
		this.b = b;
		this.c = c;
		ab = Line(a, b);
		ac = Line(a, c);
		bc = Line(b, c);
		abDirection = getDirectionForLine(ab, c);
		acDirection = getDirectionForLine(ac, b);
		bcDirection = getDirectionForLine(bc, a);
		/*
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
		}*/
	}
	
	public bool isPointInTriangle(Point p){
		if(
			isPointOnRightSideOfLine(ab, abDirection, p) &&
			isPointOnRightSideOfLine(ac, acDirection, p) &&
			isPointOnRightSideOfLine(bc, bcDirection, p)
		){
			return true;
		}else{
			return false;
		}
		/*
		if((p[1] - ab.func(p[0]))*abDirection <= 0){
			return false;
		}
		if((p[1] - ac.func(p[0]))*acDirection <= 0){
			return false;
		}
		if((p[1] - bc.func(p[0]))*bcDirection <= 0){
			return false;
		}
		return true;
		*/
	}
	
	private bool isPointOnRightSideOfLine(Line line, double direction, Point point){
		double fudge = -1*double.epsilon*2;
		if(line.verticalLine){
			if((point.x - line.verticalLineXPos)*direction < fudge){
				return false;
			}else{
				return true;
			}
		}
		if((point.y - line.func(point.x))*direction < fudge){
			return false;
		}else{
			return true;
		}
	}
	
	private double getDirectionForLine(Line line, Point thirdPoint){
		if(line.verticalLine){
			if(line.verticalLineXPos <= thirdPoint.x){
				return 1;
			}else{
				return -1;
			}
		}
		if(line.func(thirdPoint.x) <= thirdPoint.y){
			return 1;
		}else{
			return -1;
		}
	}
	
}

public struct Line{
	
	double slope, yIntercept;
	bool verticalLine = false;
	double verticalLineXPos;
	
	this(Point a, Point b){
		if(a.x == b.x){
			verticalLine = true;
			verticalLineXPos = a.x;
		}else{
			slope = (a.y-b.y)/(a.x-b.x);
		}
		yIntercept = -1*slope*a.x+a.y;
	}
	
	public double func(double x){
		return slope*x+yIntercept;
	}
	
	public Point getInterction(Line l2){
		double x = ((-1*yIntercept)+l2.yIntercept)/(slope-l2.slope);
		double y = (slope*x)+yIntercept;
		Point p;
		p.x = x;
		p.y = y;
		return p;
	}
	
}




public struct HeightMapTriangle{
	
	double heightA, heightB, heightC;
	
	PointInTriangleCheck check;
	
	this(Point pointA, double heightA, Point pointB, double heightB, Point pointC, double heightC){
		check = PointInTriangleCheck(pointA, pointB, pointC);
		this.heightA = heightA;
		this.heightB = heightB;
		this.heightC = heightC;
	}
	
	public void putTriangleOnMap(HeightMap map){
		for(int x = cast(int)floor(minNumber([check.a.x, check.b.x, check.c.x]))-1; x <= ceil(maxNumber([check.a.x, check.b.x, check.c.x]))+1; x++){
			for(int y = cast(int)floor(minNumber([check.a.y, check.b.y, check.c.y]))-1; y <= ceil(maxNumber([check.a.y, check.b.y, check.c.y]))+1; y++){
				if(check.isPointInTriangle(Point(x, y))){
					map[x][y] = cleanHeightToRawShortValue(getHeightOfPointOnTriangle(Point(x,y)));
				}
			}
		}
	}
	
	public double getHeightOfPointOnTriangle(Point p){
		double areaA = getAreaOfTriangle(p, check.b, check.c);
		double areaB = getAreaOfTriangle(check.a, p, check.c);
		double areaC = getAreaOfTriangle(check.a, check.b, p);
		double totalArea = areaA + areaB + areaC;
		double percentA = areaA/totalArea;
		double percentB = areaB/totalArea;
		double percentC = areaC/totalArea;
		return (heightA*percentA)+(heightB*percentB)+(heightC*percentC);
		
		/*
		Line sideLine = Line(check.a, check.b);
		Line thruLine = Line(p, check.c);
		Point sidePoint = sideLine.getInterction(thruLine);
		double sidePointHieght = getHeightForPointBetween2OtherPoints(sidePoint, check.z, heightA, check.b, heightB);
		return getHeightForPointBetween2OtherPoints(p, sidePoint, sidePointHieght, check.c, heightC);*/
	}
	
}

public double getHeightForPointBetween2OtherPoints(Point p, Point p1, double h1, Point p2, double h2){
	double distTo1 = getDistance(p, p1);
	double distTo2 = getDistance(p, p2);
	double percent1 = distTo1/(distTo1+distTo2);
	double percent2 = distTo2/(distTo1+distTo2);
	return (percent2*h1)+(percent1*h2);
}

public double getAreaOfTriangle(Point a, Point b, Point c){
	return abs(.5*(
			a.x*(b.y-c.y)+
			b.x*(c.y-a.y)+
			c.x*(a.y-b.y)
	));
}

public void putTriangleOnMapRotated(Point pointA, double heightA, Point pointB, double heightB, Point pointC, double heightC, Point around, double[] radians){
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




public double minNumber(double[] f){
	double min = f[0];
	int i = 1;
	while(i < f.length){
		if(f[i] < min){
			min = f[i];
		}
		i++;
	}
	return min;
}

public double maxNumber(double[] f){
	double max = f[0];
	int i = 1;
	while(i < f.length){
		if(f[i] > max){
			max = f[i];
		}
		i++;
	}
	return max;
}

alias DistanceToHeightFunc = double function(double);

public double distanceToHeight_Hill(double maxDistance, double heightIncreaseAsDistaceDecreases,  double minHeight, double maxHeight)(double distance){
	double height = ((maxDistance-distance)*heightIncreaseAsDistaceDecreases)+minHeight;
	if(height > maxHeight){
		height = maxHeight;
	}
	return height;
}


public void putCircleRotated(Point center, double radius, DistanceToHeightFunc distanceToHeightFunc, Point pointToRotateAround,double[] roations){
	for(int i = 0; i < roations.length; i++){
		Point circleCenter = rotateCord(center, pointToRotateAround, roations[i]);
		putCircle(circleCenter, radius, distanceToHeightFunc);
	}
}

public void putCircle(Point circleCenter, double radius, DistanceToHeightFunc distanceToHeightFunc){
	for(int x = cast(int)(floor(circleCenter.x-radius)); x <= cast(int)(ceil(circleCenter.x+radius)); x++){
		for(int y = cast(int)(floor(circleCenter.y-radius)); y <= cast(int)(ceil(circleCenter.y+radius)); y++){
			double distanceFromCircleCenter = getDistance(circleCenter, Point(cast(double)x,cast(double)y));
			if(distanceFromCircleCenter <= radius){
				map[x][y] = cleanHeightToRawShortValue(distanceToHeightFunc(distanceFromCircleCenter));
			}
		}
	}
}















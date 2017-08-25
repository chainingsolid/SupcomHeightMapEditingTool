import std.algorithm;
import app;
import std.stdio;
import std.parallelism;

/*
	Height Features to create
	
*/
public abstract class HeightFeature{
	
	public abstract bool hasHeightForPoint(Point point);
	
	public abstract HeightValue getHeightForPoint(Point point);
	
	public abstract void rotateAroundPointOnMap(Point around, double radians);
	
	public abstract void rotateFeature(double radians);
	
	public abstract void translateFeature(double deltaX, double deltaY);
	
	public abstract HeightFeature copy();
	
	public abstract void roundPointsToNearestInteger();
	
}


public class HeightFeatureCircle : HeightFeature{
	
	Point center;
	double radius;
	DistanceToHeightFunc distanceToHeightFunc;
	HeightValue heightValueReturnSettings;
	
	this(Point center, double radius, DistanceToHeightFunc distanceToHeightFunc, HeightValue heightValueReturnSettings){
		this.center = center;
		this.radius = radius;
		this.distanceToHeightFunc = distanceToHeightFunc;
		this.heightValueReturnSettings = heightValueReturnSettings;
	}
	
	
	public override bool hasHeightForPoint(Point point){
		if(getDistance(center, point) <= radius){
			return true;
		}else{
			return false;
		}
	}
	
	public override HeightValue getHeightForPoint(Point point){
		HeightValue heightValue;
		heightValue.howToHandleNewHeight = heightValueReturnSettings.howToHandleNewHeight;
		heightValue.priority = heightValueReturnSettings.priority;
		heightValue.height = distanceToHeightFunc(getDistance(center, point));
		return heightValue;
	}
	
	public override void rotateAroundPointOnMap(Point around, double radians){
		center = rotateCord(center, around, radians);
	}
	
	public override void rotateFeature(double radians){}
	
	public override void translateFeature(double deltaX, double deltaY){
		center.x += deltaX;
		center.y += deltaY;
	}
	
	public override HeightFeature copy(){
		return new HeightFeatureCircle(center, radius, distanceToHeightFunc, heightValueReturnSettings);
	}
	
	public override void roundPointsToNearestInteger(){
		center.roundPointToNearestIntergerLocation();
	}
	
}

public class HeightFeatureTriangle : HeightFeature{
	
	Point pointA, pointB, pointC;
	double heightA, heightB, heightC;
	HeightValue returnSettings;
	
	this(Point pointA, Point pointB, Point pointC, double heightA, double heightB, double heightC, HeightValue returnSettings){
		this.pointA = pointA;
		this.pointB = pointB;
		this.pointC = pointC;
		this.heightA = heightA;
		this.heightB = heightB;
		this.heightC = heightC;
		this.returnSettings = returnSettings;
	}
	
	public override bool hasHeightForPoint(Point point){
		double triangleABCArea = getAreaOfTriangle(pointA, pointB, pointC);
		double triangleABPArea = getAreaOfTriangle(pointA, pointB, point);
		double triangleAPCArea = getAreaOfTriangle(pointA, point, pointC);
		double trianglePBCArea = getAreaOfTriangle(point, pointB, pointC);
		
		double totalPointTriangleArea = triangleABPArea + triangleAPCArea + trianglePBCArea;
		
		if(totalPointTriangleArea <= (triangleABCArea+(double.epsilon*2))){
			return true;
		}else{
			return false;
		}
	}
	
	public override HeightValue getHeightForPoint(Point point){
		HeightValue value;
		value.howToHandleNewHeight = returnSettings.howToHandleNewHeight;
		value.priority = returnSettings.priority;
		
		double areaA = getAreaOfTriangle(point, pointB, pointC);
		double areaB = getAreaOfTriangle(pointA, point, pointC);
		double areaC = getAreaOfTriangle(pointA, pointB, point);
		double totalArea = areaA + areaB + areaC;
		double percentA = areaA/totalArea;
		double percentB = areaB/totalArea;
		double percentC = areaC/totalArea;
		value.height = (heightA*percentA)+(heightB*percentB)+(heightC*percentC);
		
		return value;
	}
	
	public override void rotateAroundPointOnMap(Point around, double radians){
		pointA = rotateCord(pointA, around, radians);
		pointB = rotateCord(pointB, around, radians);
		pointC = rotateCord(pointC, around, radians);
	}
	
	public override void rotateFeature(double radians){
		writeln("HeightFeatureTriangle.rotateFeature(double radians) is not implemented");
	}
	
	public override void translateFeature(double deltaX, double deltaY){
		pointA.x += deltaX;
		pointA.y += deltaY;
		pointB.x += deltaX;
		pointB.y += deltaY;
		pointC.x += deltaX;
		pointC.y += deltaY;
	}
	
	public override HeightFeature copy(){
		HeightFeatureTriangle newTriangle = new HeightFeatureTriangle(pointA, pointB, pointC, heightA, heightB, heightC, returnSettings);
		return newTriangle;
	}
	
	public override void roundPointsToNearestInteger(){
		pointA.roundPointToNearestIntergerLocation();
		pointB.roundPointToNearestIntergerLocation();
		pointC.roundPointToNearestIntergerLocation();
	}
	
}




public struct HeightValue{
	//Higher is more important
	int priority;
	double height;
	HowToHandleNewHeight howToHandleNewHeight;
	
	bool opEquals(HeightValue v){
		return priority == v.priority;
	}
	
	int opCmp(HeightValue v){
		return priority - v.priority;
	}
	
}

public enum HowToHandleNewHeight{
	OVER_WRITE_PREVIOUS_VALUE,
	ADD_TO_PREVIOUS_VALUE,
	OVER_WRITE_IF_HIGHER_THAN_PERVIOUS,
	OVER_WRITE_IF_LOWER_THAN_PREVIOUS,
	AVERAGE_WITH_PREVIOUS
}

public struct HeightMapGenerator{
	
	HeightFeature[] features;
	int width, height;
	HeightMap map;
	double startingHieght;
	
	this(int width, int height, double defaultHeight){
		this.width = width;
		this.height = height;
		map = makeHieghtMap(width, height, cleanHeightToRawShortValue(defaultHeight));
		startingHieght = defaultHeight;
	}
	
	public void addFeature(HeightFeature feature){
		features ~= feature;
	}
	
	public void genHeightMap(){
		foreach(HeightFeature feature; features){
			feature.roundPointsToNearestInteger();
		}
		Point[] points = genPoints();
		foreach(i, ref Point p; taskPool().parallel(points)){
			HeightValue[] valuesForPoint;
			foreach(HeightFeature feature; features){
				if(feature.hasHeightForPoint(p)){
					valuesForPoint ~= feature.getHeightForPoint(p);
				}
			}
			map[cast(int)p.x][cast(int)p.y] = cleanHeightToRawShortValue(getHeightGivenHeightValues(valuesForPoint, startingHieght));
		}
	}
	
	private Point[] genPoints(){
		Point[] points;
		points.length = width*height;
		int i = 0;
		for(int x = 0; x < width; x++){
			for(int y = 0; y < height; y++){
				points[i] = Point(x,y);
				i++;
			}
		}
		return points;
	}
	
}

public double getHeightGivenHeightValues(HeightValue[] values, double startingHeight){
	double currentHeightValue = startingHeight;
	sort(values);
	
	for(int i = 0; i < values.length; i++){
		HeightValue value = values[i];
		final switch(value.howToHandleNewHeight){
			case HowToHandleNewHeight.OVER_WRITE_PREVIOUS_VALUE:
				currentHeightValue = value.height;
				break;
			case HowToHandleNewHeight.ADD_TO_PREVIOUS_VALUE:
				currentHeightValue += value.height;
				break;
			case HowToHandleNewHeight.OVER_WRITE_IF_HIGHER_THAN_PERVIOUS:
				if(currentHeightValue < value.height){
					currentHeightValue = value.height;
				}
				break;
			case HowToHandleNewHeight.OVER_WRITE_IF_LOWER_THAN_PREVIOUS:
				if(value.height < currentHeightValue){
					currentHeightValue = value.height;
				}
				break;
			case HowToHandleNewHeight.AVERAGE_WITH_PREVIOUS:
				currentHeightValue = (currentHeightValue+value.height)/2;
				break;
		}
	}
	
	return currentHeightValue;
}






import std.stdio;
import std.math;
import app;



public void test(){
	
	PointInTriangleCheck check = PointInTriangleCheck([0f,0f], [10f,0f], [0f,.9f]);
	writefln("Point %g, %g - %d", .6f, .5f, check.isPointInTriangle([.6f, .5f]));
	writefln("Point %g, %g - %d", 1f, 1f, check.isPointInTriangle([1f, 1f]));
	
	
	
	
	
	
	
}



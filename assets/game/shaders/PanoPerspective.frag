#pragma header

// This shader IS NOT FINISHED. You will have a tough time getting it to work properly!
// By Emil Macko

uniform float hr;
uniform float vr;
uniform float hfov;
uniform float vfov;
uniform float z;
uniform float ho;
uniform float vo;
uniform float to;
uniform float to2;

void main() {
	vec2 uv = openfl_TextureCoordv;
	
	vec2 newCoord;
	float pi = 3.1415926535897932384626433832795;
	
	//	Zoom
	uv.x = (uv.x - .5) * z + .5;
	uv.y = (uv.y - .5) * z + .5;
	
	/*
		hfov	= Horizontal FOV angle of the whole background image (in degrees).
		vfov	= Vertical FOV angle of the whole background image (in degrees).
		hr		= The ratio between the widths of the view and the background image (in pixels).
		vr		= The ratio between the heights of the view and the background image (in pixels).
		ho		= The factor of the horizontal position of the view.
		vo		= The factor of the vertical position of the view, with respect to how much the view can move within the background image.
		z		= The amount to zoom the image in or out, measured in the amount of the image to show (lower values = zoomed in).
	*/
	
	vec2 o;
	o.x = (hfov / 180.) * pi;
	o.y = (vfov / 180.) * pi;
	
	float aspect = 9. / 16.;
	
	vec2 fov;
	fov.y = o.y * vr; // 63.28125
	fov.x = atan(1. / (aspect / tan(fov.y / 2.))) * 2.; // 95.2153575004
	
	// Perspective lens width is	= 1
	// Perspective lens height is	= 9/16 = aspect
	vec3 v;
	v.x = uv.x - .5 - (ho - .5); // Width	= -0.5 ... 0.5
	v.y = (uv.y - .5) * aspect - to2 * (vo - .5); // Height	= -9/32 ... 9/32
	v.z = .5 / tan(fov.x / 2.); // Depth	= 0.912879745703 / 2
	
	// Rotate vector (View Pitch)
	float ta = (.5 - vo) * (1. - vr) * o.y * 2.; // Max rotation should be 13.3165 degrees up/down from center.
	float tz = v.z * cos(ta) - v.y * sin(ta);
	float ty = v.z * sin(ta) + v.y * cos(ta);
	v.z = tz;
	v.y = ty;
	
	// Convert to unit vector:
	float vLength = sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
	v /= vLength;
	
	float lon = atan(v.x / v.z); // Longitude
	
	float vz2 = v.x * sin(lon) + v.z * cos(lon);
	float lat = atan(v.y / vz2); // Latitude
	
	newCoord.x = lon / (o.x * hr) + .5;
	newCoord.y = lat / (o.y * vr) + to * tan((1. - vr) * (vo - .5)) + .5;
	
	// For image of 2048x1024, with FOV 180x90, and view 1280x720:
	// to	= 4.8
	// to2	= 0.41
	//	GET RID OF WRAPPING BEYOND BORDER
	vec4 newImage;
	if(newCoord.x < 0. || newCoord.y < 0. || newCoord.x > 1. || newCoord.y > 1.) {
		newImage = vec4(0., 0., 0., 1.);
	} else {
		newImage = flixel_texture2D(bitmap, newCoord);
	}
	
	gl_FragColor = newImage;
}

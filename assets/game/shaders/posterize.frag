// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
#define iChannel0 bitmap
#define texture flixel_texture2D

// variables which are empty, they need just to avoid crashing shader
uniform vec4 iMouse;

uniform float color_amt;

// end of ShadertoyToFlixel header

void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
	vec2 uv = fragCoord.xy/iResolution.xy;
	vec4 col = texture(iChannel0,uv);
    
    float colorQuality = color_amt + (iMouse.y/iResolution.y)*8.0; // (1-255)
    
	if (fragCoord.x < iMouse.x)
		fragColor = col;
	else
	{
		// output
		vec3 q = vec3(colorQuality);
		fragColor = vec4(floor(col.rgb*q)/q, texture(iChannel0, fragCoord / iResolution.xy).a);
	}
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}
// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D

// end of ShadertoyToFlixel header

uniform float multiplier;


float rand(vec2 co)
{
	return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
	fragColor = texture(iChannel0, uv);    
    fragColor.rgb += multiplier * (0.25 * vec3(rand(iTime + fragCoord / vec2(-213, 5.53)), rand(iTime - fragCoord / vec2(213, -5.53)), rand(iTime + fragCoord / vec2(213, 5.53))) - 0.125);
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}
// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D

// end of ShadertoyToFlixel header

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    vec3 inColor = texture(iChannel0, uv).xyz;
    float t = iTime;
    
    uv.x *= iResolution.x/iResolution.y;
    uv *= 20.0+5.0;
    float r = distance(uv*sin(iTime*.2), inColor.xy*vec2(sin(t*2.0), sin(t)*.1));
    float g = distance(-uv, inColor.xz*vec2(inColor.x, inColor.y));
    float b = distance(uv, inColor.zy*vec2(r, sin(t)));
    float value = abs(sin(r+t) + sin(g+t) + sin(b+t) + sin(uv.x+t) + cos(uv.y+t));
    value *= 64.0;
    r /= value;
    g /= value/(sin(t)*.5+.5);
    b /= value;
    vec3 rgb = vec3(r,g,b)+(inColor/15.);
    fragColor = vec4(rgb, texture(iChannel0, fragCoord / iResolution.xy).a);
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}
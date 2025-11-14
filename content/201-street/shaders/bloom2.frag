// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
#define iChannel0 bitmap
#define texture flixel_texture2D

// end of ShadertoyToFlixel header

float bloomCount = 30.0;
float bloomBrightness = 3.0;
float bloomThresh = 0.2; // The lower the value the stronger the effect

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = fragCoord/iResolution.xy;

    vec2 pixelSize = 1.0 / iResolution.xy;
    vec4 bloomColour;
    float bloomLevel;
    float levelWeight = 2.0;
    for (float y = -bloomCount/2.0; y < bloomCount/2.0+1.0; y += 1.0) {
        float j = y > 0.0 ? y : -y;
        float rowSize = cos(asin(clamp(mod((j+ceil(bloomCount/2.0))/ceil(bloomCount+1.0), 0.5)+0.5, 0.0, 1.0)));
       // float rowSize = 1.7; // size of blur points
        for (float x = floor(-bloomCount*rowSize/2.0); x < ceil(bloomCount*rowSize/2.0+1.0); x += 1.0) {
            vec4 colour = texture(iChannel0, uv + vec2(x, y) * pixelSize);
            float weight = 1.0/(sqrt(abs(x)+abs(y))+1.0)*sqrt(bloomCount);
            float level = (colour.r+colour.g+colour.b)/3.0;
			level = level * level * level;
            if (level < bloomThresh) {
                level = 0.0;
            }
            bloomColour = max(bloomColour, colour);
            bloomLevel += level*weight;
            levelWeight += weight;
        }
    }
    bloomLevel /= levelWeight;
    bloomLevel *= bloomBrightness;

	fragColor = texture(iChannel0, uv)*(1.0-bloomLevel)+bloomColour*bloomLevel;
    
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}
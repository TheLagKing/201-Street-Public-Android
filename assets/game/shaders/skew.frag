#pragma header

uniform float curveX;
uniform float curveY;

void main() {
    vec2 uv = openfl_TextureCoordv;

    vec2 newPos;
    newPos.x = (uv.x * (1.0 - uv.y)) + ((uv.x + curveX) * uv.y);
    newPos.y = uv.y * (1.0 + curveY);

    gl_FragColor = flixel_texture2D(bitmap, newPos);
}

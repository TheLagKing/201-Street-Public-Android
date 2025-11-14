#pragma header

uniform float grayAmount;

void main()
{
    vec4 color = texture2D(bitmap, openfl_TextureCoordv);
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));

    vec3 grayscale = vec3(gray);
    vec3 blended = mix(color.rgb, grayscale, grayAmount);

    gl_FragColor = vec4(blended, color.a);
}

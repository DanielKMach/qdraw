#version 100

precision mediump float;

// Input vertex attributes (from vertex shader)
varying vec2 fragTexCoord;
varying vec4 fragColor;

// Input uniform values
uniform sampler2D texture0;
uniform vec4 colDiffuse;

// NOTE: Add here your custom variables
uniform vec2 resolution;

void main()
{
    float x = 1.0 / 2048.0;
    float y = 1.0 / 1024.0;
    vec2 uv = fragTexCoord.xy;
    vec2 uvTop = uv + vec2(0.0, y);
    vec2 uvRight = uv + vec2(x, 0.0);
    vec2 uvTopRight = uv + vec2(x, y);

    float mCenter   = texture2D(texture0, uv).a;
    float mTop      = texture2D(texture0, uvTop).a;
    float mRight    = texture2D(texture0, uvRight).a;
    float mTopRight = texture2D(texture0, uvTopRight).a;

    float dT  = abs(mCenter - mTop);
    float dR  = abs(mCenter - mRight);
    float dTR = abs(mCenter - mTopRight);

    float delta = 0.0;
    delta = max(delta, dT);
    delta = max(delta, dR);
    delta = max(delta, dTR);
    
    gl_FragColor = vec4(1.0, 1.0, 1.0, delta) * colDiffuse * fragColor;
}

#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

// Input uniform values
uniform sampler2D texture0;
uniform vec4 colDiffuse;

// Output fragment color
out vec4 finalColor;

// NOTE: Add here your custom variables
uniform vec2 resolution = vec2(2048, 1024);

void main()
{
    float x = 1.0/resolution.x;
    float y = 1.0/resolution.y;
    vec2 uv = fragTexCoord.xy;
    vec2 uvTop = uv + vec2(0, y);
    vec2 uvRight = uv + vec2(x, 0);
    vec2 uvTopRight = uv + vec2(x, y);

    float mCenter   = texture(texture0, uv).a;
    float mTop      = texture(texture0, uvTop).a;
    float mRight    = texture(texture0, uvRight).a;
    float mTopRight = texture(texture0, uvTopRight).a;

    float dT  = abs(mCenter - mTop);
    float dR  = abs(mCenter - mRight);
    float dTR = abs(mCenter - mTopRight);

    float delta = 0.0;
    delta = max(delta, dT);
    delta = max(delta, dR);
    delta = max(delta, dTR);
    
    finalColor = vec4(1, 1, 1, delta) * colDiffuse * fragColor;
}
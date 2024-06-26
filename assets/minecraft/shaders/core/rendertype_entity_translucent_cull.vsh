#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>
#moj_import <version.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler0;
uniform sampler2D Sampler1;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform int FogShape;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec4 lightMapColor;
out vec4 overlayColor;
out vec2 texCoord0;
out vec4 normal;
out float marker;
flat out int type;
out vec4 position0;
out vec4 position1;
out vec4 position2;
out vec4 position3;
flat out int index;
flat out vec3 lightColor;
flat out float intensity;

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vec4 col = texture(Sampler0, UV0);
    marker = col.rg == vec2(195, 76) / 255 ? 1.0 : 0.0;
    marker = col.rgb == vec3(76, 195, 86) / 255 ? 2.0 : marker;
    type = int(col.b * 255);
    index = int(Color.b * 255);

    position0 = 
    position1 = 
    position2 = 
    position3 = vec4(0.0);

#if defined(_MC_1_20_4)
    vertexDistance = fog_distance(ModelViewMat, IViewRotMat * Position, FogShape);
#elif defined(_MC_1_20_5)
    vertexDistance = fog_distance(Position, FogShape);
#else
#error Unsupported version.
#endif
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color);
    lightMapColor = texelFetch(Sampler2, UV2 / 16, 0);
    overlayColor = texelFetch(Sampler1, UV1, 0);
    texCoord0 = UV0;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);

    if (marker > 0.0) {
        int paletteIndex = int(Color.g * 255);
        if (paletteIndex == 0) lightColor = vec3(1.0);
        else lightColor = texture(Sampler0, UV0 + vec2(paletteIndex % 16, paletteIndex / 16) / textureSize(Sampler0, 0)).rgb;

        intensity = Color.r;

        vec3 worldSpace = IViewRotMat * Position;
        switch (gl_VertexID % 4) {
            case 0: position0 = vec4(worldSpace, 1.0); break;
            case 1: position1 = vec4(worldSpace, 1.0); break;
            case 2: position2 = vec4(worldSpace, 1.0); break;
            case 3: position3 = vec4(worldSpace, 1.0); break;
        }

        // TODO: better vertex positions
        vec2 bottomLeftCorner = vec2(-1.0);
        vec2 topRightCorner = vec2(1.0, 0.1);
        switch (gl_VertexID % 4) {
            case 0: gl_Position = vec4(bottomLeftCorner.x, topRightCorner.y,   0, 1); break;
            case 1: gl_Position = vec4(bottomLeftCorner.x, bottomLeftCorner.y, 0, 1); break;
            case 2: gl_Position = vec4(topRightCorner.x,   bottomLeftCorner.y, 0, 1); break;
            case 3: gl_Position = vec4(topRightCorner.x,   topRightCorner.y,   0, 1); break;
        }
    }
}

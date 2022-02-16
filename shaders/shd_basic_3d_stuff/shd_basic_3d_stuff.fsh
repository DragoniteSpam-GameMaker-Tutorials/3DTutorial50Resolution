varying vec2 v_vTexcoord;
varying vec4 v_vColour;

varying vec3 v_worldPosition;
varying vec3 v_worldNormal;

uniform vec3 lightDirection;

varying float v_LightDistance;
varying vec2 v_ShadowTexcoord;

uniform sampler2D s_DepthTexture;

const vec3 UNDO = vec3(1.0, 256.0, 65536.0) / 16777215.0 * 255.0;
float fromDepthColor(vec3 color) {
    return dot(color, UNDO);
}

void main() {
    vec4 starting_color = v_vColour * texture2D(gm_BaseTexture, v_vTexcoord);
    
    vec4 lightAmbient = vec4(0.25, 0.25, 0.25, 1);
    vec3 lightDirection = normalize(lightDirection);
    
    float NdotL = max(0.0, -dot(v_worldNormal, lightDirection));
    
    vec4 final_color = starting_color * vec4(min(lightAmbient + NdotL, vec4(1)).rgb, starting_color.a);
    //gl_FragColor = final_color;
    
    vec4 sampledDepthColor = texture2D(s_DepthTexture, clamp(v_ShadowTexcoord, vec2(0), vec2(1)));
    float depthValue = fromDepthColor(sampledDepthColor.rgb);
    
    float bias = 0.0005;
    if (v_LightDistance > depthValue + bias) {
        final_color.rgb *= 0.5;
    }
    
    gl_FragColor = final_color;
}
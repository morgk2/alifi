#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform float uDistortionStrength;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;
    
    // Create glass-like distortion effect
    // Add subtle wave distortion to simulate glass refraction
    float wave1 = sin(uv.x * 8.0 + uTime * 0.5) * 0.01;
    float wave2 = cos(uv.y * 6.0 + uTime * 0.3) * 0.008;
    
    // Create circular distortion from center for more realistic glass effect
    vec2 center = vec2(0.5, 0.5);
    vec2 toCenter = uv - center;
    float distanceFromCenter = length(toCenter);
    
    // Apply radial distortion (like looking through curved glass)
    float radialDistortion = distanceFromCenter * distanceFromCenter * 0.1;
    vec2 distortedUV = uv + toCenter * radialDistortion * uDistortionStrength;
    
    // Add wave distortion
    distortedUV.x += wave1 * uDistortionStrength;
    distortedUV.y += wave2 * uDistortionStrength;
    
    // Ensure UV coordinates stay within bounds
    distortedUV = clamp(distortedUV, 0.0, 1.0);
    
    // Sample the texture with distorted coordinates
    vec4 color = texture(uTexture, distortedUV);
    
    // Add slight glass tint and enhance the effect
    vec3 glassTint = vec3(0.95, 0.98, 1.0); // Slight blue tint like real glass
    color.rgb *= glassTint;
    
    // Add subtle highlight effect near edges
    float edgeHighlight = 1.0 - smoothstep(0.0, 0.3, distanceFromCenter);
    color.rgb += edgeHighlight * 0.1 * vec3(1.0, 1.0, 1.0);
    
    fragColor = color;
}


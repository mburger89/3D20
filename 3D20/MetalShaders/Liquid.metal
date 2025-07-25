//
//  Liquid.metal
//  3D20
//
//  Created by Anson Burger on 7/25/25.
//

#include <metal_stdlib>
using namespace metal;

// Vertex input structure
struct VertexIn {
    float3 position [[attribute(0)]];
    float3 normal [[attribute(1)]];
    float2 uv [[attribute(2)]];
};

// Vertex output structure
struct VertexOut {
    float4 position [[position]];
    float3 normal;
    float2 uv;
    float3 worldPosition;
};

// Vertex shader
vertex VertexOut vertex_main(VertexIn in [[stage_in]],
                             constant float4x4 &modelMatrix [[buffer(0)]],
                             constant float4x4 &viewProjMatrix [[buffer(1)]]) {
    VertexOut out;
    float4 worldPos = modelMatrix * float4(in.position, 1.0);
    out.position = viewProjMatrix * worldPos;
    out.normal = (modelMatrix * float4(in.normal, 0.0)).xyz;
    out.uv = in.uv;
    out.worldPosition = worldPos.xyz;
    return out;
}

// Fragment shader
fragment float4 fragment_main(VertexOut in [[stage_in]],
                              // Material parameters
                              constant float &metallic [[buffer(2)]],
                              constant float &roughness [[buffer(3)]],
                              constant float &transparency [[buffer(4)]],
                              // Lighting parameters
                              float3 lightPosition [[buffer(5)]],
                              float3 lightColor [[buffer(6)]],
                              float3 cameraPosition [[buffer(7)]],
                              // Normal map for flow/distortion
                              texture2d<float> normalMap [[texture(0)]],
                              sampler normalSampler [[sampler(0)]],
                              // Environment map (optional, for reflections)
                              texturecube<float> envMap [[texture(1)]],
                              sampler envSampler [[sampler(1)]]) {

    // Sample normal map and apply distortion
    float3 normalSample = normalMap.sample(normalSampler, in.uv).xyz * 2.0 - 1.0;
    float3 normalVec = normalize(in.normal + normalSample * 0.1); // Adjust distortion strength here

    // Direction vectors
    float3 lightDir = normalize(lightPosition - in.worldPosition);
    float3 viewDir = normalize(cameraPosition - in.worldPosition);

    // Reflection vector for environment reflections
    float3 reflectDir = reflect(-viewDir, normalVec);

    // Diffuse lighting
    float diffIntensity = max(dot(normalVec, lightDir), 0.0);
    float3 diffuse = diffIntensity * lightColor;

    // Specular reflection (Blinn-Phong)
    float3 halfwayDir = normalize(lightDir + viewDir);
    float specIntensity = pow(max(dot(normalVec, halfwayDir), 0.0), 64.0); // Shininess
    float3 specular = specIntensity * lightColor;

    // Fresnel effect for realistic reflections
    float fresnel = pow(1.0 - max(dot(normalVec, viewDir), 0.0), 5.0);
    float3 reflectionColor = envMap.sample(envSampler, reflectDir).xyz;

    // Combine reflection with metallic property
    float3 color = mix(diffuse, reflectionColor, metallic);

    // Apply roughness to reflection (simulate rough surface)
    color = mix(color, specular, roughness);

    // Final color with transparency
    float alpha = transparency;

    // Optional: add internal glow or coloring for liquid effect
    // For now, leave base color as is

    return float4(color, alpha);
}

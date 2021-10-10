//
//  RenderTest.metal
//  RenderTest
//

#include <metal_stdlib>
using namespace metal;
#include "RenderTest.h"

// Vertex Shader Output
struct RenderTestVertexOut {
    float4 position [[position]];
    float pointSize [[point_size]];
    float3 color;
};

vertex RenderTestVertexOut renderPointVertex(uint vertexID [[vertex_id]],
                                    constant RenderTestUniforms &uniforms [[buffer(0)]],
                                    constant TestPoint *points [[buffer(1)]]) {
    
    RenderPointVertexOut out;
    out.position = points[vertexID].position;
    out.pointSize = uniforms.particleSize;
    out.color = float3(1,0,0);
     
    return out;
}

fragment float4 renderTestFragment(RenderTestVertexOut in [[stage_in]]) {
    return float4(in.color, 1);
}
//
//  RenderTest.metal
//  RenderTest
//

#include <metal_stdlib>
using namespace metal;
#include "RenderTest.h"

// Vertex Shader Output
struct RenderTestVertexOut {
    float4 position [[position]];
    float pointSize [[point_size]];
    float3 color;
};

vertex RenderTestVertexOut renderPointVertex(uint vertexID [[vertex_id]],
                                    constant RenderTestUniforms &uniforms [[buffer(0)]],
                                    constant TestPoint *points [[buffer(1)]]) {
    
    RenderPointVertexOut out;
    out.position = points[vertexID].position;
    out.pointSize = uniforms.particleSize;
    out.color = float3(1,0,0);
     
    return out;
}

fragment float4 renderTestFragment(RenderTestVertexOut in [[stage_in]]) {
    return float4(in.color, 1);
}


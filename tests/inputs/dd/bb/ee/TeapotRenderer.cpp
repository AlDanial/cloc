/*
 * Copyright 2013 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//--------------------------------------------------------------------------------
// TeapotRenderer.cpp
// Render a teapot
//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
// Include files
//--------------------------------------------------------------------------------
#include "TeapotRenderer.h"

//--------------------------------------------------------------------------------
// Teapot model data
//--------------------------------------------------------------------------------
#include "teapot.inl"

//--------------------------------------------------------------------------------
// Ctor
//--------------------------------------------------------------------------------
TeapotRenderer::TeapotRenderer()
{

}

//--------------------------------------------------------------------------------
// Dtor
//--------------------------------------------------------------------------------
TeapotRenderer::~TeapotRenderer()
{
    Unload();
}

void TeapotRenderer::Init()
{
    //Settings
    glFrontFace( GL_CCW );

    //Load shader
    LoadShaders( &shader_param_, "Shaders/VS_ShaderPlain.vsh",
            "Shaders/ShaderPlain.fsh" );

    //Create Index buffer
    num_indices_ = sizeof(teapotIndices) / sizeof(teapotIndices[0]);
    glGenBuffers( 1, &ibo_ );
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, ibo_ );
    glBufferData( GL_ELEMENT_ARRAY_BUFFER, sizeof(teapotIndices), teapotIndices,
            GL_STATIC_DRAW );
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, 0 );

    //Create VBO
    num_vertices_ = sizeof(teapotPositions) / sizeof(teapotPositions[0]) / 3;
    int32_t iStride = sizeof(TEAPOT_VERTEX);
    int32_t iIndex = 0;
    TEAPOT_VERTEX* p = new TEAPOT_VERTEX[num_vertices_];
    for( int32_t i = 0; i < num_vertices_; ++i )
    {
        p[i].pos[0] = teapotPositions[iIndex];
        p[i].pos[1] = teapotPositions[iIndex + 1];
        p[i].pos[2] = teapotPositions[iIndex + 2];

        p[i].normal[0] = teapotNormals[iIndex];
        p[i].normal[1] = teapotNormals[iIndex + 1];
        p[i].normal[2] = teapotNormals[iIndex + 2];
        iIndex += 3;
    }
    glGenBuffers( 1, &vbo_ );
    glBindBuffer( GL_ARRAY_BUFFER, vbo_ );
    glBufferData( GL_ARRAY_BUFFER, iStride * num_vertices_, p, GL_STATIC_DRAW );
    glBindBuffer( GL_ARRAY_BUFFER, 0 );

    delete[] p;

    UpdateViewport();
    mat_model_ = ndk_helper::Mat4::Translation( 0, 0, -15.f );

    ndk_helper::Mat4 mat = ndk_helper::Mat4::RotationX( M_PI / 3 );
    mat_model_ = mat * mat_model_;
}

void TeapotRenderer::UpdateViewport()
{
    //Init Projection matrices
    int32_t viewport[4];
    glGetIntegerv( GL_VIEWPORT, viewport );
    float fAspect = (float) viewport[2] / (float) viewport[3];

    const float CAM_NEAR = 5.f;
    const float CAM_FAR = 10000.f;
    bool bRotate = false;
    mat_projection_ = ndk_helper::Mat4::Perspective( fAspect, 1.f, CAM_NEAR, CAM_FAR );
}

void TeapotRenderer::Unload()
{
    if( vbo_ )
    {
        glDeleteBuffers( 1, &vbo_ );
        vbo_ = 0;
    }

    if( ibo_ )
    {
        glDeleteBuffers( 1, &ibo_ );
        ibo_ = 0;
    }

    if( shader_param_.program_ )
    {
        glDeleteProgram( shader_param_.program_ );
        shader_param_.program_ = 0;
    }
}

void TeapotRenderer::Update( float fTime )
{
    const float CAM_X = 0.f;
    const float CAM_Y = 0.f;
    const float CAM_Z = 700.f;

    mat_view_ = ndk_helper::Mat4::LookAt( ndk_helper::Vec3( CAM_X, CAM_Y, CAM_Z ),
            ndk_helper::Vec3( 0.f, 0.f, 0.f ), ndk_helper::Vec3( 0.f, 1.f, 0.f ) );

    if( camera_ )
    {
        camera_->Update();
        mat_view_ = camera_->GetTransformMatrix() * mat_view_
                * camera_->GetRotationMatrix() * mat_model_;
    }
    else
    {
        mat_view_ = mat_view_ * mat_model_;
    }
}

void TeapotRenderer::Render()
{
    //
    // Feed Projection and Model View matrices to the shaders
    ndk_helper::Mat4 mat_vp = mat_projection_ * mat_view_;

    // Bind the VBO
    glBindBuffer( GL_ARRAY_BUFFER, vbo_ );

    int32_t iStride = sizeof(TEAPOT_VERTEX);
    // Pass the vertex data
    glVertexAttribPointer( ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, iStride,
            BUFFER_OFFSET( 0 ) );
    glEnableVertexAttribArray( ATTRIB_VERTEX );

    glVertexAttribPointer( ATTRIB_NORMAL, 3, GL_FLOAT, GL_FALSE, iStride,
            BUFFER_OFFSET( 3 * sizeof(GLfloat) ) );
    glEnableVertexAttribArray( ATTRIB_NORMAL );

    // Bind the IB
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, ibo_ );

    glUseProgram( shader_param_.program_ );

    TEAPOT_MATERIALS material = { { 1.0f, 0.5f, 0.5f }, { 1.0f, 1.0f, 1.0f, 10.f }, {
            0.1f, 0.1f, 0.1f }, };

    //Update uniforms
    glUniform4f( shader_param_.material_diffuse_, material.diffuse_color[0],
            material.diffuse_color[1], material.diffuse_color[2], 1.f );

    glUniform4f( shader_param_.material_specular_, material.specular_color[0],
            material.specular_color[1], material.specular_color[2],
            material.specular_color[3] );
    //
    //using glUniform3fv here was troublesome
    //
    glUniform3f( shader_param_.material_ambient_, material.ambient_color[0],
            material.ambient_color[1], material.ambient_color[2] );

    glUniformMatrix4fv( shader_param_.matrix_projection_, 1, GL_FALSE, mat_vp.Ptr() );
    glUniformMatrix4fv( shader_param_.matrix_view_, 1, GL_FALSE, mat_view_.Ptr() );
    glUniform3f( shader_param_.light0_, 100.f, -200.f, -600.f );

    glDrawElements( GL_TRIANGLES, num_indices_, GL_UNSIGNED_SHORT, BUFFER_OFFSET(0) );

    glBindBuffer( GL_ARRAY_BUFFER, 0 );
    glBindBuffer( GL_ELEMENT_ARRAY_BUFFER, 0 );
}

bool TeapotRenderer::LoadShaders( SHADER_PARAMS* params,
        const char* strVsh,
        const char* strFsh )
{
    GLuint program;
    GLuint vert_shader, frag_shader;
    char *vert_shader_pathname, *frag_shader_pathname;

    // Create shader program
    program = glCreateProgram();
    LOGI( "Created Shader %d", program );

    // Create and compile vertex shader
    if( !ndk_helper::shader::CompileShader( &vert_shader, GL_VERTEX_SHADER, strVsh ) )
    {
        LOGI( "Failed to compile vertex shader" );
        glDeleteProgram( program );
        return false;
    }

    // Create and compile fragment shader
    if( !ndk_helper::shader::CompileShader( &frag_shader, GL_FRAGMENT_SHADER, strFsh ) )
    {
        LOGI( "Failed to compile fragment shader" );
        glDeleteProgram( program );
        return false;
    }

    // Attach vertex shader to program
    glAttachShader( program, vert_shader );

    // Attach fragment shader to program
    glAttachShader( program, frag_shader );

    // Bind attribute locations
    // this needs to be done prior to linking
    glBindAttribLocation( program, ATTRIB_VERTEX, "myVertex" );
    glBindAttribLocation( program, ATTRIB_NORMAL, "myNormal" );
    glBindAttribLocation( program, ATTRIB_UV, "myUV" );

    // Link program
    if( !ndk_helper::shader::LinkProgram( program ) )
    {
        LOGI( "Failed to link program: %d", program );

        if( vert_shader )
        {
            glDeleteShader( vert_shader );
            vert_shader = 0;
        }
        if( frag_shader )
        {
            glDeleteShader( frag_shader );
            frag_shader = 0;
        }
        if( program )
        {
            glDeleteProgram( program );
        }

        return false;
    }

    // Get uniform locations
    params->matrix_projection_ = glGetUniformLocation( program, "uPMatrix" );
    params->matrix_view_ = glGetUniformLocation( program, "uMVMatrix" );

    params->light0_ = glGetUniformLocation( program, "vLight0" );
    params->material_diffuse_ = glGetUniformLocation( program, "vMaterialDiffuse" );
    params->material_ambient_ = glGetUniformLocation( program, "vMaterialAmbient" );
    params->material_specular_ = glGetUniformLocation( program, "vMaterialSpecular" );

    // Release vertex and fragment shaders
    if( vert_shader )
        glDeleteShader( vert_shader );
    if( frag_shader )
        glDeleteShader( frag_shader );

    params->program_ = program;
    return true;
}

bool TeapotRenderer::Bind( ndk_helper::TapCamera* camera )
{
    camera_ = camera;
    return true;
}


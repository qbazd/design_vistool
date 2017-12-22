module designVisTool.glEntityDisks;

import std.string;
import std.stdio;
import std.random;

import designVisTool.gl;

struct disk_t {
  GLfloat [2] position;
  GLfloat disk_size;
  GLfloat color;
};

struct glDisks{

  // vars
  GLuint m_Program;

  auto rnd = Random(42);

  GLuint m_Vao;
  GLuint m_Vbo;

  GLuint m_Mvp;

  GLuint position_index;
  GLuint color_index;

  disk_t[] vertex_data;

  struct shader_params_t{
    float [2] screen_wh = [800.0f,800.0f];
    float border_size = 1.0f;
    float [2] vis_min_max =        [0.0f,0.0f];
    float [2] screen_offset =      [0.0f,0.0f];
    float [2] screen_offset_drag = [0.0f,0.0f];
  };

  shader_params_t m_shader_params;

  // realize
  void realize(){
      m_Program = compileAndLinkShadersVGF( VertShaderCode, GeomShaderCode, FragShaderCode);
      initBuffers();
  }

  // unrealize
  void unrealize(){
      glDeleteBuffers(1, &m_Vao);
      glDeleteProgram(m_Program);
  }

  void update_geometry(float [] arr){

    vertex_data.length = arr.length/4;

    for (size_t i = 0; i < vertex_data.length; i++ ){
      vertex_data[i].position[0] = arr[(i * 4) + 0] / 20.0;
      vertex_data[i].position[1] = arr[(i * 4) + 1] / 20.0;
      vertex_data[i].disk_size =   arr[(i * 4) + 2] / 10.0;
      vertex_data[i].color =       arr[(i * 4) + 3];
    }
/+ 
    vertex_data.length = 10000;

    for (size_t i = 0; i < vertex_data.length; i++){

      vertex_data[i].position[0] = uniform( 0.0L, 800.0L, rnd);
      vertex_data[i].position[1] = uniform( 0.0L, 800.0L, rnd);
      vertex_data[i].disk_size =   uniform(10.0L,  20.0L, rnd);
      vertex_data[i].color =       uniform( 0.0L,   1.0L, rnd);

    }
+/    
  }

  void clear_geometry(){

    vertex_data.length = 20000;

    for (size_t i = 0; i < vertex_data.length; i++){
      vertex_data[i].position[0] = uniform( 0.0L, 800.0L, rnd);
      vertex_data[i].position[1] = uniform( 0.0L, 800.0L, rnd);
      vertex_data[i].disk_size =   uniform(10.0L,  20.0L, rnd);
      vertex_data[i].color =       uniform( 0.0L,   1.0L, rnd);
    }

  }

// render()
  void render()
  {
    //immutable mvp = getIdentityMatrix();
    //update_geometry();
    //writeln("vert len ", vertex_data.length);

    glUseProgram(m_Program);

    GLuint loc = 0;
    //# kulki pdate params

    loc = glGetUniformLocation(m_Program, "screen_hw");
    glUniform2f(loc, m_shader_params.screen_wh[0], m_shader_params.screen_wh[1]);

    loc = glGetUniformLocation(m_Program, "alpha");
    glUniform1f(loc, 1.0);

    loc = glGetUniformLocation(m_Program, "border_size");
    glUniform1f(loc, m_shader_params.border_size);

    loc = glGetUniformLocation(m_Program, "vis_min_max");
    glUniform2f(loc, 0.0, 1.0);

    loc = glGetUniformLocation(m_Program, "screen_offset");
    glUniform2f(loc, m_shader_params.screen_offset_drag[0] + m_shader_params.screen_offset[0] , m_shader_params.screen_offset_drag[1] + m_shader_params.screen_offset[1]);


    glBindVertexArray(m_Vao);

    glBindBuffer(GL_ARRAY_BUFFER, m_Vbo);
    // update vertex data
    glBufferSubData(GL_ARRAY_BUFFER, 0, vertex_data.length * disk_t.sizeof, vertex_data.ptr);

    glDrawArrays (GL_POINTS, 0, cast(int) vertex_data.length ); // liczba dysków

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    glUseProgram(0);

  }


  void initBuffers()
  {

    clear_geometry();

    glGenVertexArrays(1, &m_Vao);
    glBindVertexArray(m_Vao);

    glGenBuffers(1, &m_Vbo);
    glBindBuffer(GL_ARRAY_BUFFER, m_Vbo);
    glBufferData(GL_ARRAY_BUFFER, vertex_data.length * disk_t.sizeof, vertex_data.ptr, GL_DYNAMIC_DRAW);

    int stride = disk_t.sizeof;

    GLuint loc_pos = glGetAttribLocation(m_Program, "position");
    glEnableVertexAttribArray(loc_pos);
    glVertexAttribPointer(loc_pos, 2, GL_FLOAT, GL_FALSE, stride, cast(const void*)(0 * GLfloat.sizeof));

    GLuint loc_disk_size = glGetAttribLocation(m_Program, "disk_size_in");
    glEnableVertexAttribArray(loc_disk_size);
    glVertexAttribPointer(loc_disk_size, 1, GL_FLOAT, GL_FALSE, stride, cast(const void*)(2 * GLfloat.sizeof));

    GLuint loc_color_in = glGetAttribLocation(m_Program, "color_in");
    glEnableVertexAttribArray(loc_color_in);
    glVertexAttribPointer(loc_color_in, 1, GL_FLOAT, GL_FALSE, stride, cast(const void*)(3 * GLfloat.sizeof));

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
  }

immutable VertShaderCode = `
#version 430 core

layout(location = 0) in vec2 position;
layout(location = 1) in vec2 quadCoordIn;
layout(location = 2) in float disk_size_in;
layout(location = 3) in float color_in;
// bool disk_enabled;

uniform vec2 screen_hw;
uniform float alpha;
uniform vec2 vis_min_max;
uniform vec2 screen_offset;

out VS_OUT {
    vec3 disk_size;
    vec3 color;
} vs_out;

out float color;

vec3 HeatMapColor(float value, float minValue, float maxValue)
{
    #define HEATMAP_COLORS_COUNT 6
    vec3 colors[HEATMAP_COLORS_COUNT] =
    {
        vec3(0.32, 0.00, 0.32),
        vec3(0.00, 0.00, 1.00),
        vec3(0.00, 1.00, 0.00),
        vec3(1.00, 1.00, 0.00),
        vec3(1.00, 0.60, 0.00),
        vec3(1.00, 0.00, 0.00),
    };
    float ratio=(HEATMAP_COLORS_COUNT-1.0)*clamp((value-minValue)/(maxValue-minValue),0.0,1.0);
    float indexMin=floor(ratio);
    float indexMax=min(indexMin+1,HEATMAP_COLORS_COUNT-1);
    return mix(colors[int(indexMin)], colors[int(indexMax)], ratio-indexMin);
}


void main() {

    vs_out.disk_size = vec3(disk_size_in / screen_hw.x, disk_size_in / screen_hw.y, disk_size_in);
    vs_out.color = HeatMapColor(color_in, vis_min_max.x, vis_min_max.y);

    vec2 pos = position - (screen_offset * vec2(-1.0,1.0));

    gl_Position = vec4(2.0 * (pos.x - (screen_hw.x/2.0 ) )/ screen_hw.x, 2.0 * (pos.y - (screen_hw.y /2.0)) / screen_hw.y,0.0f,1.0f); 

}
`;


}
immutable GeomShaderCode = `
#version 430 core

layout (points) in;
layout (triangle_strip, max_vertices = 4) out;

in VS_OUT {
    vec3 disk_size;
    vec3 color;
} gs_in[];


out vec2 quadCoord;
out float disk_size;
out vec3 fColor;

//uniform vec2 screen_hw;

void build_quad(vec4 position)
{    
    disk_size = gs_in[0].disk_size.z;
    fColor = gs_in[0].color;

    quadCoord = vec2(-1.0, -1.0) * 0.5;
    gl_Position = position + vec4( vec2(-1.0, -1.0) * gs_in[0].disk_size.xy, 0.0, 0.0); // 1:bottom-left   
    EmitVertex();   

    quadCoord = vec2( 1.0, -1.0) * 0.5;
    gl_Position = position + vec4( vec2( 1.0, -1.0) * gs_in[0].disk_size.xy, 0.0, 0.0); // 2:bottom-right
    EmitVertex();

    quadCoord = vec2(-1.0,  1.0) * 0.5;
    gl_Position = position + vec4( vec2(-1.0,  1.0) * gs_in[0].disk_size.xy, 0.0, 0.0); // 3:top-left
    EmitVertex();

    quadCoord = vec2( 1.0,  1.0) * 0.5;
    gl_Position = position + vec4( vec2( 1.0,  1.0) * gs_in[0].disk_size.xy, 0.0, 0.0); // 4:top-right
    EmitVertex();

    EndPrimitive();
}

void main() {    
    build_quad(gl_in[0].gl_Position);
}
`;

immutable FragShaderCode = `
#version 430 core

// global input variables
uniform float alpha;
uniform float border_size;
uniform vec2  screen_hw;

in vec2  quadCoord;
in float disk_size;
in vec3  fColor;
out vec4 outputColor;

float clamp2(float v,float vmin,float vmax,float cmin,float cmax) {
    return clamp( (v-vmin) / (vmax-vmin), cmin, cmax);
}

void main()
{
    float disk_r = disk_size / 2.0;
    float r = sqrt(pow(quadCoord.x,2) + pow(quadCoord.y,2)) * 2.0 * disk_r;
    //float border_size = 5.0;
    vec3 bordercolor = vec3(0.0f,0.1f,0.2f);

    float al = clamp2(r, disk_r , disk_r - 1.0, 0.0, 1.0); 
    float mix_ar = clamp2(r, disk_r - border_size, disk_r - 1.0 - border_size, 0.0, 1.0); 
    outputColor = vec4(mix(bordercolor,fColor, mix_ar), al * alpha);

}
`;

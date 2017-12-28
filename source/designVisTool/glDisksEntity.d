module designVisTool.glDisksEntity;

import std.random;
import std.stdio;

import designVisTool.gl;

import glamour.gl;
import glamour.vao: VAO;
import glamour.shader: Shader;
import glamour.vbo: Buffer, ElementBuffer;

import gl3n.linalg;
import gl3n.math;

struct glDiskStruct {
  GLfloat [2] position;
  GLfloat disk_size;
  GLfloat color;
};

class glDisks{

// change to vec2
  struct shader_params_t{
    float border_size = 0.1f;
    float alpha = 1.0f;
    float [2] vis_min_max =    [0.0f,100.0f];
  };

  shader_params_t params;

  glDiskStruct [] disks;
  VAO vao_;
  Shader program_;
  Buffer vbo_;
  
  auto rnd = Random(42);

  void update_geometry(float [] arr){


    disks.length = arr.length/4;

    for (size_t i = 0; i < disks.length; i++ ){
      disks[i].position[0] = arr[(i * 4) + 0] / 10.0;
      disks[i].position[1] = arr[(i * 4) + 1] / 10.0;
      disks[i].disk_size =   arr[(i * 4) + 2] / 10.0;
      disks[i].color =       arr[(i * 4) + 3] ;
    }
  }

  void clear_geometry(){

    disks.length = 20000;

    for (size_t i = 0; i < disks.length; i++){
      disks[i].position[0] = uniform( 0.0L, 800.0L, rnd);
      disks[i].position[1] = uniform( 0.0L, 800.0L, rnd);
      disks[i].disk_size =   uniform(10.0L,  20.0L, rnd);
      disks[i].color =       uniform( 0.0L,   1.0L, rnd);
    }

  }

  this()
  {

    clear_geometry();

    // Create program
    program_ = new Shader("disks_shader", disks_shader_src_);
    vao_ = new VAO();
    vbo_ = new Buffer(disks, GL_DYNAMIC_DRAW);

    vao_.bind();
      vbo_.bind();
      {
        auto al = program_.get_attrib_location("position");
        glEnableVertexAttribArray(al);
        glVertexAttribPointer(al, 2, GL_FLOAT, GL_FALSE, glDiskStruct.sizeof, cast(const void*)(0 * GLfloat.sizeof));
      }
      {
        auto al = program_.get_attrib_location("disk_size_in");
        glEnableVertexAttribArray(al);
        glVertexAttribPointer(al, 2, GL_FLOAT, GL_FALSE, glDiskStruct.sizeof, cast(const void*)(2 * GLfloat.sizeof));
      }
      {
        auto al = program_.get_attrib_location("color_in");
        glEnableVertexAttribArray(al);
        glVertexAttribPointer(al, 2, GL_FLOAT, GL_FALSE, glDiskStruct.sizeof, cast(const void*)(3 * GLfloat.sizeof));
      }
      vbo_.unbind();
    vao_.unbind();

  }


  void draw(mat4 mvp)
  {

    //version(console) writeln("render disks");

    vbo_.update(disks,0);

    program_.bind();

      program_.uniform1f("border_size", params.border_size);
      program_.uniform1f("alpha", params.alpha);
      program_.uniform2f("vis_min_max", params.vis_min_max[0],params.vis_min_max[1]);
      program_.uniform("mvp", mvp);

      vao_.bind();
      glDrawArrays(GL_POINTS, 0, cast(int) disks.length ); 
      vao_.unbind();    

    program_.unbind();

  }

  void close()
  {
    // free resources
    vbo_.remove();
    vao_.remove();
    program_.remove();
    disks = null;
  }

private static immutable string disks_shader_src_ = q{
#version 330 core
vertex:

layout(location = 0) in vec2 position;
layout(location = 1) in vec2 quadCoordIn;
layout(location = 2) in float disk_size_in;
layout(location = 3) in float color_in;
// bool disk_enabled;

uniform float alpha;
uniform vec2 vis_min_max;
uniform mat4 mvp;

out VS_OUT {
    float disk_size;
    vec3 color;
    mat4 mvp;
} vs_out;

out float color;

vec3 HeatMapColor(float value, float minValue, float maxValue)
{
    #define HEATMAP_COLORS_COUNT 6
    vec3 colors[HEATMAP_COLORS_COUNT];
    
    colors[0] = vec3(0.32, 0.00, 0.32);
    colors[1] = vec3(0.00, 0.00, 1.00);
    colors[2] = vec3(0.00, 1.00, 0.00);
    colors[3] = vec3(1.00, 1.00, 0.00);
    colors[4] = vec3(1.00, 0.60, 0.00);
    colors[5] = vec3(1.00, 0.00, 0.00);
    
    float ratio=(HEATMAP_COLORS_COUNT-1.0)*clamp((value-minValue)/(maxValue-minValue),0.0,1.0);
    float indexMin=floor(ratio);
    float indexMax=min(indexMin+1,HEATMAP_COLORS_COUNT-1);
    return mix(colors[int(indexMin)], colors[int(indexMax)], ratio-indexMin);
}


void main() {
    vs_out.disk_size = disk_size_in;
    vs_out.color = HeatMapColor(color_in, vis_min_max.x, vis_min_max.y);
    vs_out.mvp = mvp;
    gl_Position = vec4(position,0.0,1.0); 
}

geometry:

layout (points) in;
layout (triangle_strip, max_vertices = 4) out;

in VS_OUT {
    float disk_size;
    vec3 color;
    mat4 mvp;
} gs_in[];

out vec2 quadCoord;
out float disk_size;
out vec3 fColor;

//uniform vec2 screen_hw;

void build_quad()
{    
    disk_size = gs_in[0].disk_size;
    fColor = gs_in[0].color;

    quadCoord = vec2(-1.0, -1.0) * 0.5;
    gl_Position = gs_in[0].mvp * (gl_in[0].gl_Position + ( vec4( vec2(-1.0, -1.0) * gs_in[0].disk_size, 0.0,1.0))); // 1:bottom-left   
    EmitVertex();   

    quadCoord = vec2( 1.0, -1.0) * 0.5;
    gl_Position = gs_in[0].mvp * (gl_in[0].gl_Position + ( vec4( vec2( 1.0, -1.0) * gs_in[0].disk_size, 0.0,1.0))); // 2:bottom-right
    EmitVertex();

    quadCoord = vec2(-1.0,  1.0) * 0.5;
    gl_Position = gs_in[0].mvp * (gl_in[0].gl_Position + ( vec4( vec2(-1.0,  1.0) * gs_in[0].disk_size, 0.0,1.0))); // 3:top-left
    EmitVertex();

    quadCoord = vec2( 1.0,  1.0) * 0.5;
    gl_Position = gs_in[0].mvp * (gl_in[0].gl_Position + ( vec4( vec2( 1.0,  1.0) * gs_in[0].disk_size, 0.0,1.0))); // 4:top-right
    EmitVertex();

    EndPrimitive();
}

void main() {    
    build_quad();
}

fragment:

  // global input variables
  uniform float alpha;
  uniform float border_size;
  // uniform vec2  screen_hw;

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
};


}




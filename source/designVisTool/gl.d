module designVisTool.gl;

import glamour.gl;

import std.string;
import std.stdio;
import std.conv;

import gl3n.linalg;
import gl3n.math;

vec2i to_i(vec2 v){return vec2i(v.x.to!int, v.y.to!int);}


uint compileShader(int type, string source)
{
  const shader = glCreateShader(type);
  scope(failure) glDeleteShader(shader);
  const(char)*srcPtr = source.ptr;
  
  glShaderSource(shader, 1, &srcPtr, null);
  glCompileShader(shader);

  int status;
  glGetShaderiv(shader, GL_COMPILE_STATUS, &status);

  if(status == GL_FALSE)
  {
    int len;
    glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &len);

    char[] buffer;
    buffer.length = len + 1;
    glGetShaderInfoLog(shader, len, null, buffer.ptr);

    string sType = "unknown"; 
    // switch 
    switch (type)
    {
    case GL_VERTEX_SHADER: sType = "vertex"; break;
    case GL_FRAGMENT_SHADER: sType = "fragment"; break;
    case GL_GEOMETRY_SHADER: sType = "geometry"; break;
    default: sType = "unknown"; break;
    }

    throw new Exception(format("Compilation failure in %s shader: %s", sType, buffer));
  }

  return shader;
}

uint compileAndLinkShadersVGF(string  vertShaderCode, string  geomShaderCode , string  fragShaderCode ){

  const program = glCreateProgram();

  const vertex = compileShader(GL_VERTEX_SHADER, vertShaderCode ~ "\0");
  scope(exit) glDeleteShader(vertex);
  glAttachShader(program, vertex);
  scope(exit) glDetachShader(program, vertex);

  const geometry = compileShader(GL_GEOMETRY_SHADER, geomShaderCode ~ "\0");
  scope(exit) glDeleteShader(geometry);
  glAttachShader(program, geometry);
  scope(exit) glDetachShader(program, geometry);

  const fragment = compileShader(GL_FRAGMENT_SHADER, fragShaderCode ~ "\0");
  scope(exit) glDeleteShader(fragment);
  glAttachShader(program, fragment);
  scope(exit) glDetachShader(program, fragment);

  glLinkProgram(program);

  int status = 0;
  glGetProgramiv(program, GL_LINK_STATUS, &status);

  if(status == GL_FALSE)
  {
    int len = 0;
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &len);

    char[] buffer;
    buffer.length = len + 1;
    glGetProgramInfoLog(program, len, null, buffer.ptr);

    glDeleteProgram(program);

    throw new Exception(format("Linking failure in program: %s", buffer));
  }

  return program;
}

uint compileAndLinkShadersVF(string  vertShaderCode, string  fragShaderCode ){

  const program = glCreateProgram();

  const vertex = compileShader(GL_VERTEX_SHADER, vertShaderCode ~ "\0");
  scope(exit) glDeleteShader(vertex);
  glAttachShader(program, vertex);
  scope(exit) glDetachShader(program, vertex);

  const fragment = compileShader(GL_FRAGMENT_SHADER, fragShaderCode ~ "\0");
  scope(exit) glDeleteShader(fragment);
  glAttachShader(program, fragment);
  scope(exit) glDetachShader(program, fragment);

  glLinkProgram(program);

  int status = 0;
  glGetProgramiv(program, GL_LINK_STATUS, &status);

  if(status == GL_FALSE)
  {
    int len = 0;
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &len);

    char[] buffer;
    buffer.length = len + 1;
    glGetProgramInfoLog(program, len, null, buffer.ptr);

    glDeleteProgram(program);

    throw new Exception(format("Linking failure in program: %s", buffer));
  }

  return program;
}

float[16] getIdentityMatrix() pure
{
  float[4 * 4] mat;

  // identity matrix
  for(int x=0;x < 4;++x)
    for(int y=0;y < 4;++y)
      mat[x+y*4] = x==y ? 1 : 0;

  return mat;
}

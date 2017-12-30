module designVisTool.gl;

import glamour.gl;

import std.string;
import std.stdio;
import std.conv;

import gl3n.linalg;
import gl3n.math;

vec2i to_i(vec2 v){return vec2i(v.x.to!int, v.y.to!int);}


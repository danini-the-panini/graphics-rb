require 'docile'

require 'opengl'
require 'glfw'

require_relative './ffi_utils.rb'

include OpenGL
include GLFW

include FFIUtils

module Shader
  POSITION_LOC = 1
  NORMAL_LOC = 2

  @@shaders = {}
  @@current_shader = nil

  def shaders; @@shaders; end
  def current_shader; @@current_shader; end
  def use_shader sym
    if sym.nil? or shaders[sym].nil?
      @@current_shader = nil
      glUseProgram(0)
    else
      shaders[sym].use
    end
  end

  def load_shader file, type
    return -1 if file.nil?

    source = IO.read file
    return -1 if source.nil?

    handle = glCreateShader type

    glShaderSource handle, 1, strarr([source]), nil
    glCompileShader handle

    log = shader_log handle
    puts log unless log.nil?

    handle
  end

  def shader_log handle
    ptr = ' '*8
    glGetShaderiv handle, GL_COMPILE_STATUS, ptr
    if ptr.unpack('L')[0] == GL_FALSE
      glGetShaderiv handle, GL_INFO_LOG_LENGTH, ptr
      length = ptr.unpack('L')[0]

      if length > 0
          log = ' '*length
          glGetShaderInfoLog handle, length, ptr, log
          log.unpack("A#{length}")[0]
      end
    else
      nil
    end
  end

  def program_log handle
    ptr = ' '*8
    glGetProgramiv handle, GL_LINK_STATUS, ptr
    if ptr.unpack('L')[0] == GL_FALSE
      glGetProgramiv handle, GL_INFO_LOG_LENGTH, ptr
      length = ptr.unpack('L')[0]

      if length > 0
          log = ' '*length
          glGetProgramInfoLog handle, length, ptr, log
          log.unpack("A#{length}")[0]
      end
    else
      nil
    end
  end

  class Shader
    def initialize vertex, geometry, tess_control, tess_eval, fragment
      @uniforms = {}

      vertex_handle = load_shader vertex, GL_VERTEX_SHADER
      geometry_handle = load_shader geometry, GL_GEOMETRY_SHADER
      tess_control_handle = load_shader tess_control, GL_TESS_CONTROL_SHADER
      tess_eval_handle = load_shader tess_eval, GL_TESS_EVALUATION_SHADER
      fragment_handle = load_shader fragment, GL_FRAGMENT_SHADER

      @handle = glCreateProgram

      glAttachShader @handle, vertex_handle unless vertex_handle == -1
      glAttachShader @handle, geometry_handle unless geometry_handle == -1
      glAttachShader @handle, tess_control_handle unless tess_control_handle == -1
      glAttachShader @handle, tess_eval_handle unless tess_eval_handle == -1
      glAttachShader @handle, fragment_handle unless fragment_handle == -1

      glLinkProgram @handle

      log = program_log @handle
      puts log unless log.nil?
    end

    def use
      glUseProgram @handle
      @@current_shader = self
    end
    def find_uniform name
      @uniforms[name] ||= glGetUniformLocation @handle, name.to_s
    end

    def update_mat4 name, value
      glUniformMatrix4fv find_uniform(name), 1, GL_FALSE, f_arr(value.transpose.to_a.flatten)
    end
    def update_float name, value
      glUniform1f find_uniform(name), value.to_f
    end
    def update_vec3 name, value
      glUniform3fv find_uniform(name), 1, f_arr(value.to_a)
    end
    def update_vec4 name, value
      glUniform4fv find_uniform(name), 1, f_arr(value.to_a)
    end
    def update_int name, value
      glUniform1i find_uniform(name), value.to_i
    end

  end

  class ShaderBuilder
    def initialize
      @vertex = @geometry = @tess_control = @tess_eval = @fragment = nil
    end
    def vertex(v); @vertex = v; self; end
    def geometry(v); @geometry = v; self; end
    def tess_control(v); @tess_control = v; self; end
    def tess_eval(v); @tess_eval = v; self; end
    def fragment(v); @fragment = v; self; end
    def build
      Shader.new @vertex, @geometry, @tess_control, @tess_eval, @fragment
    end
  end

  def shader sym=nil, &block
    unless block_given?
      shaders[sym]
    else
      obj = Docile.dsl_eval(ShaderBuilder.new, &block).build
      shaders[sym] = obj unless sym.nil?
      obj
    end
  end
end

require 'docile'
require 'matrix'
require_relative './matrices.rb'

require_relative './shader.rb'
require_relative './ffi_utils.rb'

include OpenGL
include GLFW

include FFIUtils

module Mesh

  @@meshes = {}

  FACE_SIZE = 3
  POINT_SIZE = 3
  NORMAL_SIZE = 3
  VERTEX_SIZE = 6

  def meshes; @@meshes; end

  def draw sym, type=GL_TRIANGLES
    meshes[sym].draw type
  end

  def unbind
    glBindVertexArray 0
  end

  class Mesh
    def initialize points, normals, faces
      ptr = ' '*8
      glGenVertexArrays 1, ptr
      @handle = ptr.unpack('L')[0]

      @points = points
      @normals = normals
      @faces = faces

      @vertices = []

      (0...points.size).each do |i|
        @vertices << points[i].x << points[i].y << points[i].z
        @vertices << normals[i].x << normals[i].y << normals[i].z
      end

      bind

      glGenBuffers(1, ptr)
      glBindBuffer(GL_ARRAY_BUFFER, ptr.unpack('L')[0])

      glBufferData(GL_ARRAY_BUFFER, @vertices.size * SIZEOF_FLOAT,
              f_arr(@vertices), GL_STATIC_DRAW)

      glGenBuffers(1, ptr)
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ptr.unpack('L')[0])

      glBufferData(GL_ELEMENT_ARRAY_BUFFER, @faces.size * SIZEOF_INT,
              i_arr(@faces), GL_STATIC_DRAW)

      glEnableVertexAttribArray(Shader::POSITION_LOC)
      glVertexAttribPointer(Shader::POSITION_LOC, POINT_SIZE, GL_FLOAT, GL_FALSE,
              VERTEX_SIZE * SIZEOF_FLOAT, 0)

      glEnableVertexAttribArray(Shader::NORMAL_LOC)
      glVertexAttribPointer(Shader::NORMAL_LOC, NORMAL_SIZE, GL_FLOAT, GL_FALSE,
              VERTEX_SIZE * SIZEOF_FLOAT, POINT_SIZE * SIZEOF_FLOAT)
    end

    def bind
      glBindVertexArray @handle
    end

    def draw type=GL_TRIANGLES
      bind

      glPatchParameteri(GL_PATCH_VERTICES, 3) if type == GL_PATCHES
      glDrawElements type, @faces.size, GL_UNSIGNED_INT, 0
    end
  end

  class MeshBuilder
    def initialize
      @points = []
      @normals = []
      @faces = []
    end
    def point(x,y,z); @points << Vector[x,y,z]; self; end
    def normal(x,y,z); @normals << Vector[x,y,z]; self; end
    def face(a,b,c); @faces << a << b << c; self; end
    def build
      Mesh.new @points, @normals, @faces
    end
  end

  def mesh sym, &block
    meshes[sym] = Docile.dsl_eval(MeshBuilder.new, &block).build
  end
end

require 'docile'
require 'matrix'
require_relative './matrices.rb'
require_relative './spline.rb'

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

  def meshes; x = @@meshes; end

  def draw sym, type=GL_TRIANGLES
    mesh = meshes[sym]
    mesh.draw type unless mesh.nil?
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
    def pointv(v); @points << v; self; end
    def point(x,y,z); pointv Vector[x,y,z]; self; end
    def normalv(v); @normals << v; self; end
    def normal(x,y,z); normalv Vector[x,y,z]; self; end
    def face(a,b,c); @faces << a << b << c; self; end

    def cube o={}
      w = (o[:width] || 1)*0.5
      h = (o[:height] || 1)*0.5
      d = (o[:depth] || 1)*0.5

      point -w, -h, -d
      point -w, -h,  d
      point  w, -h,  d
      point  w, -h, -d
      point -w,  h, -d
      point -w,  h,  d
      point  w,  h,  d
      point  w,  h, -d

      normal 0, 1, 0
      normal 0, 1, 0
      normal 0, 1, 0
      normal 0, 1, 0
      normal 0, 1, 0
      normal 0, 1, 0
      normal 0, 1, 0
      normal 0, 1, 0

      # top
      face 0, 1, 2
      face 0, 2, 3

      # bottom
      face 5, 4, 6
      face 6, 4, 7

      # right
      face 6, 7, 2
      face 2, 7, 3

      # left
      face 4, 5, 1
      face 4, 1, 0

      # front
      face 1, 5, 6
      face 1, 6, 2

      # back
      face 4, 0, 7
      face 7, 0, 3
    end

    def quad o={}
      w = (o[:width] || 1)*0.5
      l = (o[:length] || 1)*0.5

      point -w, -1, -l
      point -w, -1,  l
      point  w, -1,  l
      point  w, -1, -l

      normal 0, 1, 0
      normal 0, 1, 0
      normal 0, 1, 0
      normal 0, 1, 0

      face 1, 0, 2
      face 2, 0, 3
    end

    def sweep s, t, o={}
      step_s = o[:step_s] || 0.1
      step_t = o[:step_t] || 0.1

      spl_s = splines[s]
      spl_t = splines[t]

      (0..1).step(step_s) do |i|
        (0..1).step(step_t) do |j|
          pointv spl_s.p(i) + spl_t.p(j)
          normal 0, 1, 0 # todo: work out normal
        end
      end
      (0..1/step_s-1).each do |i|
        (0..1/step_t-1).each do |j|
          a = 1/step_t*i + j
          b = a + 1
          c = a + 1/step_t
          d = c + 1
          face a, b, d
          face a, d, c
        end
      end
      self
    end

    def sweep_simple s, t
      spl_s = splines[s]
      spl_t = splines[t]

      (0...spl_s.size).each do |i|
        (0...spl_t.size).each do |j|
          pointv spl_s[i] + spl_t[j]
          normal 0, 1, 0 # todo: work out normal
        end
      end
      (0...spl_s.size-1).each do |i|
        (0...spl_t.size-1).each do |j|
          a = spl_t.size*i + j
          b = a + 1
          c = a + spl_t.size
          d = c + 1
          face a, b, d
          face a, d, c
        end
      end
      self
    end

    def lathe s, o={}
      step_s = o[:step_s] || 0.1
      step_t = o[:step_t] || 0.1
      angle = o[:angle] || 360
      axis = o[:axis] || Vector[0,1,0]

      spl = splines[s]

      (0..1).step(step_s) do |i|
        (0..1).step(step_t) do |j|
          p = Matrices.rotate(Matrix.I(4), j*angle, axis) * spl.p(i).to_pnt
          point p.x, p.y, p.z
          normal 0, 1, 0 # todo: work out normal
        end
      end
      (0..1/step_s-1).each do |i|
        (0..1/step_t-1).each do |j|
          a = 1/step_t*i + j
          b = a + 1
          c = a + 1/step_t
          d = c + 1
          face a, b, d
          face a, d, c
        end
      end
      self
    end

    def lathe_simple s, o={}
      step = o[:step] || 0.1
      angle = o[:angle] || 360
      axis = o[:axis] || Vector[0,1,0]

      spl = splines[s]

      (0...size).each do |i|
        (0..1).step(step) do |j|
          p = Matrices.rotate(Matrix.I(4), j*angle, axis) * spl[i].to_pnt
          point p.x, p.y, p.z
          normal 0, 1, 0 # todo: work out normal
        end
      end
      (0...size-1).each do |i|
        (0..1/step-1).each do |j|
          a = 1/step*i + j
          b = a + 1
          c = a + 1/step
          d = c + 1
          face a, b, d
          face a, d, c
        end
      end
      self
    end

    def build
      Mesh.new @points, @normals, @faces
    end
  end

  def mesh sym, &block
    meshes[sym] = Docile.dsl_eval(MeshBuilder.new, &block).build
  end
end

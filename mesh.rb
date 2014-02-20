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

  def draw_mesh sym, type=GL_TRIANGLES
    mesh = meshes[sym]
    mesh.draw type unless mesh.nil?
  end

  def unbind
    glBindVertexArray 0
  end

  class Mesh
    def initialize points, normals, faces, calculate_normals
      ptr = ' '*8
      glGenVertexArrays 1, ptr
      @handle = ptr.unpack('L')[0]

      @points = points
      @faces = faces

      unless calculate_normals
        @normals = normals
      else
        adjacent = []
        @points.each_index do |i|
          adjacent[i] ||= []
        end
        (0...@faces.size).step(3) do |i|
          these = @faces[i...i+3]
          v = these.collect { |j| @points[j] }
          n = (v[0]-v[1]).cross(v[0]-v[2]).normalize
          these.each do |f|
            adjacent[f] << n
          end
        end
        @normals = adjacent.collect { |n| n.empty? ? Vector[0,1,0] : n.inject(:+).normalize }
      end

      @vertices = []

      (0...@points.size).each do |i|
        @vertices << @points[i].x << @points[i].y << @points[i].z
        @vertices << @normals[i].x << @normals[i].y << @normals[i].z
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

      position_loc = current_shader.find_attribute :position

      glEnableVertexAttribArray position_loc
      glVertexAttribPointer(position_loc, POINT_SIZE, GL_FLOAT, GL_FALSE,
              VERTEX_SIZE * SIZEOF_FLOAT, 0)

      normal_loc = current_shader.find_attribute :normal
      glEnableVertexAttribArray normal_loc
      glVertexAttribPointer(normal_loc, NORMAL_SIZE, GL_FLOAT, GL_FALSE,
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
    def calculate_normals(v=true); @calculate_normals = v; self; end
    def face(a,b,c); @faces << a << b << c; self; end

    def cube o={}
      w = (o[:width] || 1)*0.5
      h = (o[:height] || 1)*0.5
      d = (o[:depth] || 1)*0.5

      n = @points.size

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
      face n+0, n+1, n+2
      face n+0, n+2, n+3

      # bottom
      face n+5, n+4, n+6
      face n+6, n+4, n+7

      # right
      face n+6, n+7, n+2
      face n+2, n+7, n+3

      # left
      face n+4, n+5, n+1
      face n+4, n+1, n+0

      # front
      face n+1, n+5, n+6
      face n+1, n+6, n+2

      # back
      face n+4, n+0, n+7
      face n+7, n+0, n+3
    end

    def quad o={}
      w = (o[:width] || 1)*0.5
      l = (o[:length] || 1)*0.5

      n = @points.size

      point -w, 0, -l
      point -w, 0,  l
      point  w, 0,  l
      point  w, 0, -l

      normal n+0, n+1, n+0
      normal n+0, n+1, n+0
      normal n+0, n+1, n+0
      normal n+0, n+1, n+0

      face 1, 0, 2
      face 2, 0, 3
    end

    # Generation of geometry in lathe function.
    # The rotation matrix is used to rotate the spline around the origin given the specified angle.
    # The faces are then generated as if the points were on a grid.
    def lathe s, o={}
      step_s = o[:step_s] || 0.1
      step_t = o[:step_t] || 0.1
      angle = o[:angle] || 360
      axis = o[:axis] || Vector[0,1,0]

      spl = splines[s]

      n = @points.size

      # generate vertices
      (0..1).step(step_s) do |i|
        (0..1).step(step_t) do |j|
          rot = Matrices.rotate(Matrix.I(4), j*angle, axis)
          pointv Vector.elements (rot * spl.p(i).to_pnt)[0...3]
        end
      end
      # generate faces
      (0..1/step_s-1).each do |i|
        (0..1/step_t-1).each do |j|
          a = 1/step_t*i + j
          b = a + 1
          c = a + 1/step_t
          d = c + 1
          face n+a, n+b, n+d
          face n+a, n+d, n+c
        end
      end
      calculate_normals
      self
    end

    def build
      Mesh.new @points, @normals, @faces, !!@calculate_normals
    end
  end

  def mesh sym=nil, &block
    unless block_given?
      meshes[sym]
    else
      obj = Docile.dsl_eval(MeshBuilder.new, &block).build
      meshes[sym] = obj unless sym.nil?
      obj
    end
  end
end

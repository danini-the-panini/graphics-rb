require 'docile'

require_relative './matrices.rb'
require_relative './mesh.rb'

include Mesh

module Shape

  @@shapes = {}

  def shapes; @@shapes; end

  def draw_shape sym
    shape = shapes[sym]
    shape.draw unless shape.nil?
  end

  class Shape

    def initialize mesh, position, scale, rotation, colour, opacity
      @mesh = mesh
      @position = position
      @scale = scale
      @rotation = rotation
      @colour = colour
      @opacity = opacity

      matrix
    end

    def mesh; @mesh; end
    def position; @position; end
    def scale; @scale; end
    def rotation; @rotation; end
    def colour; @colour; end
    def opacity; @opacity; end

    def position=(v); @position = v; matrix; v; end
    def rotation=(v); @rotation = v; matrix; v; end
    def scale=(v); @scale = v; matrix; v; end

    def colour=(v); @colour = v; end
    def opacity=(v); @opacity = v; end

    def matrix
      @matrix = Matrix.I(4)

      @matrix = Matrices.translate @matrix, @position

      @matrix = Matrices.rotate @matrix, @rotation.z, Vector[0,0,1]
      @matrix = Matrices.rotate @matrix, @rotation.y, Vector[0,1,0]
      @matrix = Matrices.rotate @matrix, @rotation.x, Vector[1,0,0]

      @matrix = Matrices.scale @matrix, @scale
    end

    def draw
      return if mesh.nil?

      current_shader.update_mat4 :world, @matrix
      current_shader.update_vec3 :in_colour, @colour
      current_shader.update_float :opacity, @opacity

      mesh.draw
    end
  end

  class ShapeBuilder
    def initialize
      @mesh = nil
      @position = Vector[0,0,0]
      @scale = Vector[1,1,1]
      @rotation = Vector[0,0,0]
      @colour = Vector[0,0,0]
      @opacity = 1.0
    end
    def use_mesh(sym); @mesh=meshes[sym]; end
    def position(x,y,z); @position=Vector[x,y,z]; end
    def scale(x,y,z); @scale=Vector[x,y,z]; end
    def uniform_scale(v); scale v,v,v; end
    def rotation(pitch,yaw,roll); @rotation=Vector[pitch,yaw,roll]; end
    def colour(r,g,b); @colour=Vector[r,g,b]; end
    def opacity(v); @opacity=v; end
    def build
      Shape.new @mesh, @position, @scale, @rotation, @colour, @opacity
    end
  end

  def shape sym, &block
    shapes[sym] = Docile.dsl_eval(ShapeBuilder.new, &block).build
  end
end

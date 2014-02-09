require 'docile'
require 'matrix'
require_relative './matrices.rb'

module Camera
  @@cameras = {}

  def cameras; @@cameras; end

  class Camera < Struct.new(:eye, :at, :up)

    def view
      Matrices.look_at eye, at, up
    end

  end

  class CameraBuilder
    def initialize
      @eye = Vector[0,0,1]
      @at = Vector[0,0,0]
      @up = Vector[0,1,0]
    end
    def eye(x,y,z); @eye = Vector[x,y,z]; self; end
    def at(x,y,z); @at = Vector[x,y,z]; self; end
    def up(x,y,z); @up = Vector[x,y,z]; self; end
    def build
      Camera.new @eye, @at, @up
    end
  end

  def camera sym, &block
    cameras[sym] = Docile.dsl_eval(CameraBuilder.new, &block).build
  end
end

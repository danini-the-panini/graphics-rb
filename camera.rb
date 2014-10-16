require 'docile'
require 'matrix'
require_relative './matrices.rb'

module Camera
  @@cameras = {}

  def cameras; @@cameras; end

  class Camera

    def initialize _eye, _at, _up
      @eye = _eye; @at = _at; @up = _up
      recalc
    end

    def view
      Matrices.look_at eye, at, up
    end

    def eye= v
      @eye = v
      recalc
      @eye
    end

    def at= v
      @at = v
      recalc
      @at
    end

    def up= v
      @up = v
      recalc
      @up
    end

    def eye; @eye; end
    def at; @at; end
    def up; @up; end

    def d; @d; end
    def right; @right; end
    def real_up; @real_up; end

    private
    def recalc
      @d = (@at - @eye).normalize
      @right = @up.cross(@d).normalize
      @real_up = @d.cross(@right).normalize
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

  def camera sym=nil, &block
    unless block_given?
      cameras[sym]
    else
      obj = Docile.dsl_eval(CameraBuilder.new, &block).build
      cameras[sym] = obj unless sym.nil?
      obj
    end
  end
end

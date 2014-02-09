require 'docile'
require 'matrix'
require_relative './matrices.rb'
require_relative './lense.rb'

module Orthographic

  class Orthographic < Struct.new(:left, :right, :bottom, :top, :z_near, :z_far)

    def projection aspect
      Matrices.ortho left, right, bottom, top, z_near, z_far
    end

  end

  class OrthographicBuilder
    def initialize
      @left = @bottom = @z_near = -1
      @right = @top = @z_far = 1
    end
    def left(v); @left = v; self; end
    def right(v); @right = v; self; end
    def bottom(v); @bottom = v; self; end
    def top(v); @top = v; self; end
    def z_near(v); @z_near = v; self; end
    def z_far(v); @z_far = v; self; end
    def build
      Orthographic.new @left, @right, @bottom, @top, @z_near, @z_far
    end
  end

  def orthographic sym, &block
    Lense::lenses[sym] = if block.nil?
      OrthographicBuilder.new.build
    else
      Docile.dsl_eval(OrthographicBuilder.new, &block).build
    end
  end
end

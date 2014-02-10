require 'docile'
require 'matrix'
require_relative './matrices.rb'
require_relative './lense.rb'

include Matrices

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

  def orthographic sym=nil, &block
    unless block_given?
      lenses[sym]
    else
      obj = Docile.dsl_eval(OrthographicBuilder.new, &block).build
      lenses[sym] = obj unless sym.nil?
      obj
    end
  end
end

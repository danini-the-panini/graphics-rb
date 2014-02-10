require 'docile'
require 'matrix'
require_relative './matrices.rb'
require_relative './lense.rb'

module Perspective

  class Perspective < Struct.new(:fovy, :ratio, :z_near, :z_far)

    def projection aspect
      Matrices.perspective fovy, aspect*ratio, z_near, z_far
    end

  end

  class PerspectiveBuilder
    def initialize
      @fovy = 45.0
      @ratio = 1.0
      @z_near = 0.1
      @z_far = 100
    end
    def fovy(v); @fovy = v; self; end
    def ratio(v); @ratio = v; self; end
    def z_near(v); @z_near = v; self; end
    def z_far(v); @z_far = v; self; end
    def build
      Perspective.new @fovy, @ratio, @z_near, @z_far
    end
  end

  def perspective sym=nil, &block
    unless block_given?
      lenses[sym]
    else
      obj = Docile.dsl_eval(PerspectiveBuilder.new, &block).build
      lenses[sym] = obj unless sym.nil?
      obj
    end
  end
end

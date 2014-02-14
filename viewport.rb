require 'docile'

module Viewport
  @@viewports = {}

  def viewports; @@viewports; end

  Viewport = Struct.new(:top, :left, :width, :height, :shader_blocks,
    :bg, :camera, :lense, :light)

  class ViewportBuilder
    def initialize
      @top = @left = 0.0
      @width = @height = 1.0
      @bg = Vector[0,0,0,0]
      @shader_blocks = {}
      @camera = @lense = nil
      @light = nil
    end
    def top(v); @top = v; self; end
    def left(v); @left = v; self; end
    def width(v); @width = v; self; end
    def height(v); @height = v; self; end
    def bg(r,g,b,a=1); @bg = Vector[r,g,b,a]; self; end
    def use_camera(v); @camera = v; self; end
    def use_lense(v); @lense = v; self; end
    def use_light(v); @light = v; self; end
    def with_shader(s,&v); @shader_blocks[s] = v; self; end
    def build
      Viewport.new @top, @left, @width, @height, @shader_blocks, @bg, @camera, @lense, @light
    end
  end

  def viewport sym=nil, &block
    unless block_given?
      viewports[sym]
    else
      obj = Docile.dsl_eval(ViewportBuilder.new, &block).build
      viewports[sym] = obj unless sym.nil?
      obj
    end
  end
end

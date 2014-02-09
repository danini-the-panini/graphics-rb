require 'docile'

module Viewport
  @@viewports = {}

  def viewports; @@viewports; end

  Viewport = Struct.new(:top, :left, :width, :height, :block, :bg)

  class ViewportBuilder
    def initialize
      @top = @left = 0.0
      @width = @height = 1.0
      @bg = Vector[0,0,0,0]
      @block = lambda {}
    end
    def top(v); @top = v; self; end
    def left(v); @left = v; self; end
    def width(v); @width = v; self; end
    def height(v); @height = v; self; end
    def bg(r,g,b,a=1); @bg = Vector[r,g,b,a]; self; end
    def each_frame(&v); @block = v; self; end
    def build
      Viewport.new @top, @left, @width, @height, @block, @bg
    end
  end

  def viewport sym, &block
    viewports[sym] = Docile.dsl_eval(ViewportBuilder.new, &block).build
  end
end

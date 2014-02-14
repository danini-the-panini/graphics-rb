require 'docile'

module Viewport

  @@current_viewport = nil
  def curreent_viewport; @@curreent_viewport; end

  class Viewport < Struct.new(:top, :left, :width, :height, :block,:bg)
    def use screen_width, screen_height
      x, y, w, h = (screen_width*left).to_i, (screen_height*(1.0-top-height)).to_i, (screen_width*width).to_i, (screen_height*height).to_i
      glViewport x, y, w, h
      glScissor x, y, w, h
      glClearColor *bg
      glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT

      @@current_viewport = self

      w.to_f / h.to_f
    end
  end

  class ViewportBuilder
    def initialize
      @top = @left = 0.0
      @width = @height = 1.0
      @bg = Vector[0,0,0,0]
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
end

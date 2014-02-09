
require 'opengl'
require 'glfw'

require 'matrix'
require_relative './matrices.rb'

require 'docile'

require_relative './viewport.rb'

OpenGL.load_dll
GLFW.load_dll

include OpenGL
include GLFW

module Graphics
  include Viewport

  glfwInit

  # Press ESC to exit.
  @@esc_to_exit_callback = GLFW::create_callback :GLFWkeyfun do |window_handle, key, scancode, action, mods|
    if key == GLFW_KEY_ESCAPE && action == GLFW_PRESS
      glfwSetWindowShouldClose window_handle, 1
    end
  end

  def gl_begin mode
    glBegin mode
    yield
    glEnd
  end

  class Window

    def initialize opt={}
      @width = opt[:width] ||= 800
      @height = opt[:height] ||= 600
      opt[:title] ||= "OpenGL App"
      @handle = glfwCreateWindow( @width, @height, opt[:title], nil, nil )

      yield

      glfwMakeContextCurrent @handle
      glfwSetKeyCallback @handle, @@esc_to_exit_callback

      glEnable GL_SCISSOR_TEST

      while glfwWindowShouldClose(@handle) == 0

        width_ptr = '        '
        height_ptr = '        '
        glfwGetFramebufferSize @handle, width_ptr, height_ptr
        @width = width_ptr.unpack('L')[0]
        @height = height_ptr.unpack('L')[0]

        viewports.each_value do |vp|
          x, y, w, h = (@width*vp.left).to_i, (@height*(vp.height-vp.top)).to_i, (@width*vp.width).to_i, (@height*vp.height).to_i
          glViewport x, y, w, h
          glScissor x, y, w, h
          glClearColor *vp.bg
          glClear GL_COLOR_BUFFER_BIT

          ratio = w.to_f / h.to_f

          vp.block.yield

        end

        glfwSwapBuffers @handle
        glfwPollEvents
      end

      glfwDestroyWindow @handle
      glfwTerminate
    end
  end
end

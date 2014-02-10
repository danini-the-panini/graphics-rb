
require 'opengl'
require 'glfw'

require 'matrix'
require_relative './matrices.rb'

require 'docile'

require_relative './viewport.rb'
require_relative './camera.rb'
require_relative './lense.rb'
require_relative './perspective.rb'
require_relative './orthographic.rb'
require_relative './shader.rb'
require_relative './mesh.rb'
require_relative './camera_control.rb'
require_relative './spline.rb'

OpenGL.load_dll
GLFW.load_dll

include OpenGL
include GLFW

module Graphics
  include Viewport
  include Camera
  include Lense
  include Perspective
  include Orthographic
  include Shader
  include Mesh

  glfwInit

  @@error_callback = GLFW::create_callback :GLFWerrorfun do |error, description|
    puts "ERROR #{error}: #{decription}"
  end

  glfwSetErrorCallback @@error_callback

  @@windows = {}
  @@handle = 0

  def windows; @@windows; end

  # Press ESC to exit.
  @@esc_to_exit_callback = GLFW::create_callback :GLFWkeyfun do |window, key, scancode, action, mods|
    if key == GLFW_KEY_ESCAPE && action == GLFW_PRESS
      glfwSetWindowShouldClose window, 1
    end
  end


  def gl_begin mode
    glBegin mode
    yield
    glEnd
  end

  def add_control control
    glfwSetKeyCallback(         @@handle, control.key_fun          ) unless control.key_fun.nil?
    glfwSetCharCallback(        @@handle, control.char_fun         ) unless control.char_fun.nil?
    glfwSetMouseButtonCallback( @@handle, control.mouse_button_fun ) unless control.mouse_button_fun.nil?
    glfwSetCursorPosCallback(   @@handle, control.cursor_pos_fun   ) unless control.cursor_pos_fun.nil?
    glfwSetCursorEnterCallback( @@handle, control.cursor_enter_fun ) unless control.cursor_enter_fun.nil?
    glfwSetScrollCallback(      @@handle, control.scroll_fun       ) unless control.scroll_fun.nil?
  end

  class Window

    def initialize title, width, height, exit_on_close
      @handle = glfwCreateWindow( width, height, title, nil, nil )
      @@handle = @handle

      glfwMakeContextCurrent @handle
      glfwSetKeyCallback @handle, @@esc_to_exit_callback if exit_on_close

      yield

      glEnable GL_SCISSOR_TEST

      while glfwWindowShouldClose(@handle) == 0

        width_ptr = ' '*8
        height_ptr = ' '*8
        glfwGetFramebufferSize @handle, width_ptr, height_ptr
        @width = width_ptr.unpack('L')[0]
        @height = height_ptr.unpack('L')[0]

        viewports.each do |tag, vp|
          x, y, w, h = (@width*vp.left).to_i, (@height*(1.0-vp.top-vp.height)).to_i, (@width*vp.width).to_i, (@height*vp.height).to_i
          glViewport x, y, w, h
          glScissor x, y, w, h
          glClearColor *vp.bg
          glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT

          aspect = w.to_f / h.to_f

          vp.block_before.yield

          unless current_shader.nil?
            current_shader.update_mat4(:view, cameras[vp.camera].view) unless cameras[vp.camera].nil?
            current_shader.update_mat4(:projection, lenses[vp.lense].projection(aspect)) unless lenses[vp.lense].nil?
          end

          vp.block.yield
        end

        glfwSwapBuffers @handle
        glfwPollEvents
      end

      glfwDestroyWindow @handle
      glfwTerminate
    end

    def handle; @handle; end
  end

  class WindowBuilder
    def initialize
      @title = 'OpenGL App'
      @width = 800; @height = 600
      @init_block
    end
    def title(v); @title = v; end
    def width(v); @width = v; end
    def height(v); @height = v; end
    def init(&v); @init_block = v; end
    def exit_on_close(v=true); @exit_on_close = v; end
    def build
      Window.new @title, @width, @height, !!@exit_on_close, &@init_block
    end
  end

  def window sym, &block
    windows[sym] = Docile.dsl_eval(WindowBuilder.new, &block).build
  end
end

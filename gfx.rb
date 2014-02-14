
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
require_relative './shape.rb'
require_relative './light.rb'

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
  include Spline
  include Shape
  include Light

  glfwInit

def core v
  v_split = v.split '.'
  glfwWindowHint GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE
  glfwWindowHint GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE
  glfwWindowHint GLFW_CONTEXT_VERSION_MAJOR, v_split[0].to_i
  glfwWindowHint GLFW_CONTEXT_VERSION_MINOR, v_split[1].to_i
  glfwWindowHint GLFW_CONTEXT_REVISION, v_split[2].to_i
end

  @@error_callback = GLFW::create_callback :GLFWerrorfun do |error, description|
    puts "ERROR #{error}: #{description}"
  end

  glfwSetErrorCallback @@error_callback

  @@handle = 0

  # Press ESC to exit.
  @@esc_to_exit_callback = GLFW::create_callback :GLFWkeyfun do |window, key, scancode, action, mods|
    if key == GLFW_KEY_ESCAPE && action == GLFW_PRESS
      glfwSetWindowShouldClose window, 1
    end
  end

  def add_control control
    glfwSetKeyCallback(         @@handle, control.key_fun          ) unless control.key_fun.nil?
    glfwSetCharCallback(        @@handle, control.char_fun         ) unless control.char_fun.nil?
    glfwSetMouseButtonCallback( @@handle, control.mouse_button_fun ) unless control.mouse_button_fun.nil?
    glfwSetCursorPosCallback(   @@handle, control.cursor_pos_fun   ) unless control.cursor_pos_fun.nil?
    glfwSetCursorEnterCallback( @@handle, control.cursor_enter_fun ) unless control.cursor_enter_fun.nil?
    glfwSetScrollCallback(      @@handle, control.scroll_fun       ) unless control.scroll_fun.nil?
  end

  def get_key key
    glfwGetKey @@handle, key
  end

  def with_shader shader
    use_shader shader
    yield
  end

  def use_camera camera
    current_shader.update_mat4(:view, cameras[camera].view) unless cameras[camera].nil?
  end

  def use_lense lense, aspect
    current_shader.update_mat4(:projection, lenses[lense].projection(aspect)) unless lenses[lense].nil?
  end

  def use_light light
    current_shader.update_vec3(:light, lights[light].point) unless lights[light].nil?
  end

  class Window

    def initialize title, width, height, exit_on_close, wireframe, viewports
      @handle = glfwCreateWindow( width, height, title, nil, nil )
      @@handle = @handle

      glfwMakeContextCurrent @handle
      glfwSwapInterval 1
      glfwSetKeyCallback @handle, @@esc_to_exit_callback if exit_on_close

      glEnable GL_SCISSOR_TEST
      glPolygonMode GL_FRONT_AND_BACK, if wireframe then GL_LINE else GL_FILL end

      yield

      while glfwWindowShouldClose(@handle) == 0

        width_ptr = ' '*8
        height_ptr = ' '*8
        glfwGetFramebufferSize @handle, width_ptr, height_ptr
        @width = width_ptr.unpack('L')[0]
        @height = height_ptr.unpack('L')[0]

        viewports.each do |vp|
          aspect = vp.use @width, @height

          vp.block.yield aspect
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

      @viewports = []
    end
    def title(v); @title = v; end
    def width(v); @width = v; end
    def height(v); @height = v; end
    def init(&v); @init_block = v; end
    def exit_on_close(v=true); @exit_on_close = v; end
    def wireframe(v=true); @wireframe = v; end

    def viewport &block
      @viewports << Docile.dsl_eval(ViewportBuilder.new, &block).build
      self
    end

    def build
      Window.new @title, @width, @height, !!@exit_on_close, !!@wireframe, @viewports, &@init_block
    end
  end

  def window &block
    Docile.dsl_eval(WindowBuilder.new, &block).build
  end
end

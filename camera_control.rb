require 'glfw'
require_relative './control.rb'
require_relative './matrices.rb'
require_relative './camera.rb'

include GLFW
include Camera

class CameraControl < Control
  def initialize sym
    mx = my = 0

    @mouse_button = GLFW::create_callback :GLFWmousebuttonfun do |window, button, action, mods|
      x_ptr = ' '*8; y_ptr = ' '*8
      glfwGetCursorPos window, x_ptr, y_ptr
      mx = x_ptr.unpack('D')[0].to_i
      my = y_ptr.unpack('D')[0].to_i
    end

    @camera_move_on_mouse = GLFW::create_callback :GLFWcursorposfun do |window, x, y|
      if glfwGetMouseButton(window,GLFW_MOUSE_BUTTON_LEFT) == GLFW_PRESS
        dx = x-mx; dy = y-my;

        m = Matrices.rotate Matrix.I(4), dy, cameras[sym].right.normalize
        m = Matrices.rotate m, dx, Vector[0,1,0]
        d2 = m * Vector.elements( cameras[sym].d.to_a + [0] )
        cameras[sym].eye = cameras[sym].at - Vector[d2.x,d2.y,d2.z]

        mx = x; my = y
      end
    end
  end

  def mouse_button_fun; @mouse_button; end
  def cursor_pos_fun; @camera_move_on_mouse; end
end

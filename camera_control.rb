require 'glfw'
require_relative './control.rb'
require_relative './matrices.rb'
require_relative './camera.rb'

include GLFW
include Camera

class CameraControl < Control
  def initialize sym
    cam = cameras[sym]
    mx = my = 0

    @mouse_button = GLFW::create_callback :GLFWmousebuttonfun do |window, button, action, mods|
      x_ptr = ' '*8; y_ptr = ' '*8
      glfwGetCursorPos window, x_ptr, y_ptr
      mx = x_ptr.unpack('D')[0].to_i
      my = y_ptr.unpack('D')[0].to_i
    end

    @camera_move_on_mouse = GLFW::create_callback :GLFWcursorposfun do |window, x, y|
      dx = x-mx; dy = y-my;
      if glfwGetMouseButton(window,GLFW_MOUSE_BUTTON_LEFT) == GLFW_PRESS
        m = Matrices.rotate Matrix.I(4), -dy, cam.right.normalize
        m = Matrices.rotate m, dx, Vector[0,1,0]
        d2 = m * Vector.elements( cam.d.to_a + [0] )
        cam.at = cam.eye + Vector[d2.x,d2.y,d2.z]
      elsif glfwGetMouseButton(window,GLFW_MOUSE_BUTTON_RIGHT) == GLFW_PRESS
        v = cam.right.normalize * dx * 0.05 + cam.real_up.normalize * dy * 0.05
        cam.eye += v
        cam.at += v
      end
      mx = x; my = y
    end

    @camera_zoom_on_scroll = GLFW::create_callback :GLFWscrollfun do |window, x, y|
      d = cam.d
      if y < 0
        (0..-y).each do |dy|
          d *= 1.05
        end
      else
        (0..y).each do |dy|
          d *= 0.95
        end
      end
      cam.eye = cam.at - d
    end
  end

  def mouse_button_fun; @mouse_button; end
  def cursor_pos_fun; @camera_move_on_mouse; end
  def scroll_fun; @camera_zoom_on_scroll; end
end

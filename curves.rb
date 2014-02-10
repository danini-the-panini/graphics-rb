require_relative './gfx.rb'

include Graphics

window :main do
  title 'Curves'
  exit_on_close

  init do
    glDisable GL_CULL_FACE
    glEnable GL_DEPTH_TEST

    shader :simple do
      vertex 'vertex.glsl'
      fragment 'fragment.glsl'
    end

    camera :main do
      eye 5, 3, 5
      at 0, 0, 0
      up 0, 1, 0
    end

    perspective :main do
      fovy 45
      z_near 0.5
      z_far 100
    end

    add_control CameraControl.new :main

    mesh :cube do
      cube
    end

    mesh :quad do
      quad
    end

    spline :a do
      control_point 1, 4, 0
      control_point 4, 1, 0
      control_point 1,-4, 0
      control_point 4,-6, 0
    end

    spline :b do
      control_point  1, 0, 0
      control_point  0, 0, 1
      control_point -1, 0, 0
      control_point  0, 0,-1
      control_point  1, 0, 0
    end

    mesh :spline do
      lathe :a
      # sweep :a, :b
    end

    viewport :main do
      bg 0, 1, 1
      use_camera :main
      use_lense :main

      before_each_frame do
        use_shader :simple
      end

      @cube_angle = 0

      each_frame do

        # current_shader.update_mat4 :world, Matrices.rotate(Matrix.I(4), @cube_angle, Vector[0,1,0])
        # current_shader.update_vec3 :in_colour, Vector[1,0,1]

        # draw :cube

        current_shader.update_mat4 :world, Matrix.I(4)
        current_shader.update_vec3 :in_colour, Vector[1,0,0]

        draw :spline

        # current_shader.update_mat4 :world, Matrices.scale(Matrix.I(4), Vector[5,1,5])
        # current_shader.update_vec3 :in_colour, Vector[0,1,0]

        # draw :quad

        @cube_angle += 1
      end
    end
  end
end

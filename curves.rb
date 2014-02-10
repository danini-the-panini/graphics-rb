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

    camera :cam_a do
      eye 5, 3, 5
      at 0, 0, 0
      up 0, 1, 0
    end

    perspective :cam_a do
      fovy 45
      z_near 0.5
      z_far 100
    end

    add_control CameraControl.new :cam_a

    mesh :cube do
      point -1, -1, -1
      point -1, -1,  1
      point  1, -1,  1
      point  1, -1, -1
      point -1,  1, -1
      point -1,  1,  1
      point  1,  1,  1
      point  1,  1, -1

      normal 0, 1, 0
      normal 0, 1, 0
      normal 0, 1, 0
      normal 0, 1, 0
      normal 0, 1, 0
      normal 0, 1, 0
      normal 0, 1, 0
      normal 0, 1, 0

      # top
      face 0, 1, 2
      face 0, 2, 3

      # bottom
      face 5, 4, 6
      face 6, 4, 7

      # right
      face 6, 7, 2
      face 2, 7, 3

      # left
      face 4, 5, 1
      face 4, 1, 0

      # front
      face 1, 5, 6
      face 1, 6, 2

      # back
      face 4, 0, 7
      face 7, 0, 3
    end

    mesh :quad do
      point -1, -1, -1
      point -1, -1,  1
      point  1, -1,  1
      point  1, -1, -1

      normal 0, 1, 0
      normal 0, 1, 0
      normal 0, 1, 0
      normal 0, 1, 0

      face 1, 0, 2
      face 2, 0, 3
    end

    spline_a = Spline.new([
      Vector[1,4,0], Vector[4,1,0], Vector[1,-4,0], Vector[4,-6,0]
    ])

    spline_b = Spline.new([
      Vector[1,0,0], Vector[0,0,1], Vector[-1,0,0], Vector[0,0,-1]
    ])

    spline_a.lathe :spline, step=0.01

    viewport :top_left do
      bg 0, 1, 1
      use_camera :cam_a
      use_lense :cam_a

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

        current_shader.update_mat4 :world, Matrices.scale(Matrix.I(4), Vector[5,1,5])
        current_shader.update_vec3 :in_colour, Vector[0,1,0]
        draw :quad

        @cube_angle += 1
      end
    end
  end
end

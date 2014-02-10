require_relative './gfx.rb'

include Graphics

Window.new title: "Curves" do

  glEnable GL_CULL_FACE
  glEnable GL_DEPTH_TEST

  shader :simple do
    vertex 'vertex.glsl'
    fragment 'fragment.glsl'
  end

  camera :cam_a do
    eye 2, 1.5, 2
    at 0, 0, 0
    up 0, 1, 0
  end

  perspective :cam_a do
    fovy 10
    z_near 0.05
    z_far 100
  end

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

  viewport :top_left do
    bg 0, 1, 0
    top 0; left 0
    width 0.5; height 0.5
    use_camera :cam_a
    use_lense :cam_a

    before_each_frame do
      use_shader :simple
    end

    @cube_angle = 0

    each_frame do

      current_shader.update_mat4 :world, Matrices.rotate(Matrix.I(4), @cube_angle, Vector[0,1,0])
      current_shader.update_vec3 :in_colour, Vector[1,0,0]

      draw :cube

      current_shader.update_mat4 :world, Matrices.scale(Matrix.I(4), Vector[5,1,5])
      current_shader.update_vec3 :in_colour, Vector[0,0,1]
      draw :quad

      @cube_angle += 1
    end
  end

  viewport :top_right do
    bg 1, 1, 0
    top 0; left 0.5
    width 0.5; height 0.5

    before_each_frame do
      use_shader nil
    end

    each_frame do

      gl_begin GL_TRIANGLES do
        glColor3f   1, 0, 1
        glVertex3f  1, 0, 0
        glVertex3f  0, 1, 0
        glVertex3f -1, 0, 0
      end

    end
  end

  viewport :bottom_left do
    bg 0, 1, 1
    top 0.5; left 0
    width 0.5; height 0.5

    each_frame do
    end
  end
end

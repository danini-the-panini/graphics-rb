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
      lathe :a, {step_s: 0.01, step_t: 0.01}
      # sweep :a, :b, {step_s: 0.01, step_t: 0.01}
    end

    shape :cube do
      use_mesh :cube
      colour 1, 0, 0
      position 0, 1, 0
      uniform_scale 2
    end

    shape :floor do
      use_mesh :quad
      colour 0, 1, 0
      position 0, -6, 0
      uniform_scale 20
    end

    shape :spline do
      use_mesh :spline
      colour 1, 0, 0
    end

    viewport :main do
      bg 0, 1, 1
      use_camera :main
      use_lense :main

      before_each_frame do
        use_shader :simple
      end

      each_frame do

        # draw_shape :cube
        # shapes[:cube].rotation += Vector[0,1,0]

        draw_shape :spline

        draw_shape :floor
      end
    end
  end
end

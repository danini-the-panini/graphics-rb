require_relative './gfx.rb'

include Graphics

window do
  title 'Curves'
  core '3.3.0'
  exit_on_close
  # wireframe

  init do
    glEnable GL_CULL_FACE
    glEnable GL_DEPTH_TEST

    shader :simple do
      vertex 'passthrough.vsh'
      geometry 'simple.gsh'
      fragment 'pplighting.fsh'
    end

    shader :normals do
      vertex 'passthrough.vsh'
      geometry 'normals.gsh'
      fragment 'flat.fsh'
    end

    use_shader :simple

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

    light :lamp do
      point 1, 2, 1
    end

    add_control CameraControl.new :main

    mesh :cube do
      wavefront 'cube.obj'
    end

    mesh :quad do
      quad
    end

    mesh :monkey do
      wavefront 'monkey.obj'
    end

    spline :a do
      control_point -0.5,-3.5, 0, 2
      control_point 3.5, 1.5, 0
      control_point 0.5, 4.5, 0
      control_point 6, 6, 0, 2
      control_point 1, 4, 0
      control_point 4, 1, 0
      control_point 0,-4, 0, 2
      control_point 6,-6, 0, 2
      control_point 0,-6, 0, 2
    end

    spline :b do
      control_point  1, 0, 0
      control_point  0, 0, 1
      control_point -1, 0, 0
      control_point  0, 0,-1
      control_point  1, 0, 0
    end

    spline :c do
      control_point  2, 1, 0
      control_point  2,-1, 0
      control_point  1, 0, 0
      control_point  2, 1, 0
      control_point  3, 0, 0
      control_point  2,-1, 0
      control_point  1, 0, 0
      control_point  2, 1, 0
      control_point  2,-1, 0
    end

    chosen_spline = :a

    mesh :spline do
      lathe chosen_spline, {step_s: 0.01, step_t: 0.01}
      # sweep :a, :b, {step_s: 0.01, step_t: 0.01}
      calculate_normals
    end

    cube_shape = shape :cube do
      use_mesh :cube
      colour 1, 0, 0
      position 0, 1, 0
      uniform_scale 2
    end

    monkey_shape = shape :monkey do
      use_mesh :monkey
      colour 1, 0, 0
      position 0, 1, 0
      uniform_scale 2
    end

    floor = shape do
      use_mesh :quad
      colour 0, 1, 0
      position 0, -6, 0
      uniform_scale 20
    end

    spline_shape = shape do
      use_mesh :spline
      colour 1, 0, 0
    end

    cp_shapes = []

    splines[chosen_spline].each_control_point do |p|
      cp_shapes << shape do
        use_mesh :cube
        colour 1, 0, 1
        position p.x, p.y, p.z
        uniform_scale 0.1
      end
    end

    viewport do
      bg 0, 1, 1

      should_draw_normals = false

      each_frame do |aspect|
        should_draw_normals = !should_draw_normals if get_key(GLFW_KEY_N) == GLFW_PRESS
        monkey_shape.rotation += Vector[0,1,0]

        with_shader :simple do
          use_camera :main
          use_lense :main, aspect
          use_light :lamp

          # draw_shape :monkey

          spline_shape.draw

          cp_shapes.each { |s| s.draw }

          floor.draw
        end

        if should_draw_normals
          with_shader :normals do
            use_camera :main
            use_lense :main, aspect
            use_light :lamp

            current_shader.update_float :normal_length, 0.1

            spline_shape.draw GL_POINTS
          end
        end
      end
    end
  end
end

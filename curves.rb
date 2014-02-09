require_relative './gfx.rb'

include Graphics

Window.new title: "Curves" do

  viewport :top_left do
    bg 1, 0, 1
    top 0; left 0
    width 0.5; height 0.5

    each_frame do

      gl_begin GL_TRIANGLES do
        glColor3f   1, 1, 1
        glVertex3f  0, 1, 0
        glVertex3f  1, 0, 0
        glVertex3f -1, 0, 0
      end

    end
  end

  viewport :top_right do
    bg 1, 1, 0
    top 0; left 0.5
    width 0.5; height 0.5

    each_frame do
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

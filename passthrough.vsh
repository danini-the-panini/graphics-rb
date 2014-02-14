#version 330

in vec3 position;
in vec3 normal;

out vec3 v_normal;

void main()
{
    v_normal = normal;

    gl_Position = vec4(position,1.0f);
}


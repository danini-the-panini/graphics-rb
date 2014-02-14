#version 330

in vec3 position;
in vec3 normal;

uniform mat4 projection;
uniform mat4 world;
uniform mat4 view;

out vec3 g_normal;
out vec3 g_position;
out vec3 eye;

void main()
{
    eye = (inverse(view) * vec4 (0, 0, 1, 1)).xyz;

    g_normal = (world * vec4(normal, 0)).xyz;

    g_position = (world * vec4(position,1)).xyz;
    gl_Position = projection * view * world * vec4(position, 1);
}

#version 330

uniform vec3 in_colour;
uniform float opacity;

layout (location = 0) out vec4 out_colour;

void main()
{
    out_colour = vec4(in_colour, opacity);
}


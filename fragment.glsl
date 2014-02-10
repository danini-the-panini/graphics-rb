#version 420

uniform vec3 in_colour;
uniform vec3 opacity;

layout (location = 0) out vec4 out_colour;

void main()
{
    out_colour = vec4(in_colour * (1.0f-gl_FragCoord.z)*10, opacity);
}


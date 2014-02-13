#version 420
layout (points) in;
layout (line_strip, max_vertices=2) out;

uniform mat4 projection;
uniform mat4 world;
uniform mat4 view;

uniform float normal_length;

in vec3 v_normal[];

vec3 lerp(vec3 a, vec3 b, float w)
{
    return a*(1.0f-w) + b*w;
}

void main()
{
    vec4 normal = normalize(world * vec4(v_normal[0], 0.0f));

    gl_Position = projection * view * world * gl_in[0].gl_Position;
    EmitVertex();

    gl_Position = projection * view * world * (gl_in[0].gl_Position+normal*normal_length);
    EmitVertex();

    EndPrimitive();
}


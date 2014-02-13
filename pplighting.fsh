#version 420

uniform vec3 in_colour;
uniform float opacity;

uniform vec3 light;

in vec3 g_normal;
in vec3 g_position;
in vec3 eye;

layout (location = 0) out vec4 out_colour;

void main()
{
    float ia = 0.3f;
    float id = 0.5f;
    float is = 1.0f;
    float s = 100.0f;

    vec3 v = normalize(eye-g_position);
    vec3 l = normalize(light);
    vec3 r = normalize(reflect(-l,g_normal));

    float ip = ia + max(dot(l,g_normal),0)*id + pow(max(dot(r,v),0),s)*is;

    out_colour = vec4(in_colour * ip, opacity);
}


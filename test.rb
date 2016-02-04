require 'opengl'
require_relative './lib/mittsu/renderers/opengl/opengl_debug'
require 'glfw'
require 'fiddle'

OpenGL.load_lib
path = `pkg-config glfw3 --libs-only-L`.chomp.strip[2..-1]
GLFW.load_lib('libglfw3.dylib', path)

include OpenGLDebug
include GLFW

def glCreateBuffer
  b = ' '*8
  glGenBuffers(1, b)
  b.unpack('L')[0]
end

def glCreateVertexArray
  b = ' '*8
  glGenVertexArrays(1, b)
  b.unpack('L')[0]
end

def pointer(data)
  size_of_element = data.first.is_a?(Float) ? Fiddle::SIZEOF_FLOAT : Fiddle::SIZEOF_INT
  format_of_element = data.first.is_a?(Float) ? 'F' : 'L'
  size = data.length * size_of_element
  Fiddle::Pointer.malloc(size).tap { |ptr|
    ptr[0,size] = data.pack(format_of_element * data.length)
  }
end

def glBufferData_easy(target, data, usage)
  ptr = pointer(data)
  glBufferData(target, ptr.size, ptr, usage)
end

def shader_log handle
  ptr = ' '*8
  glGetShaderiv handle, GL_COMPILE_STATUS, ptr
  if ptr.unpack('L')[0] == GL_FALSE
    glGetShaderiv handle, GL_INFO_LOG_LENGTH, ptr
    length = ptr.unpack('L')[0]

    if length > 0
        log = ' '*length
        glGetShaderInfoLog handle, length, ptr, log
        log.unpack("A#{length}")[0]
    end
  else
    nil
  end
end

def program_log handle
  ptr = ' '*8
  glGetProgramiv handle, GL_LINK_STATUS, ptr
  if ptr.unpack('L')[0] == GL_FALSE
    glGetProgramiv handle, GL_INFO_LOG_LENGTH, ptr
    length = ptr.unpack('L')[0]

    if length > 0
        log = ' '*length
        glGetProgramInfoLog handle, length, ptr, log
        log.unpack("A#{length}")[0]
    end
  else
    nil
  end
end

frag = File.read 'frag.glsl'
vert = File.read 'vert.glsl'

mesh = [
  0.5, 0.5, 0.5, 0.5, -0.5, 0.5, 0.5, 0.5, -0.5, 0.5, -0.5, 0.5, 0.5, -0.5, -0.5, 0.5, 0.5, -0.5, -0.5, 0.5, -0.5, -0.5,
  -0.5, -0.5, -0.5, 0.5, 0.5, -0.5, -0.5, -0.5, -0.5, -0.5, 0.5, -0.5, 0.5, 0.5, -0.5, 0.5, -0.5, -0.5, 0.5, 0.5, 0.5,
  0.5, -0.5, -0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, -0.5, -0.5, -0.5, 0.5, -0.5, -0.5, -0.5, 0.5, -0.5, 0.5, -0.5,
  -0.5, -0.5, 0.5, -0.5, -0.5, 0.5, -0.5, 0.5, -0.5, 0.5, 0.5, -0.5, -0.5, 0.5, 0.5, 0.5, 0.5, -0.5, -0.5, 0.5, 0.5,
  -0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, -0.5, 0.5, -0.5, -0.5, -0.5, 0.5, -0.5, 0.5, -0.5, -0.5, -0.5, -0.5, -0.5, -0.5,
  0.5, -0.5
]

color = [
  1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
  1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
  1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
  1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
  1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0
]

normals = [
  1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0,
  0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0,
  1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0,
  0.0, 0.0, -1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0,
  0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0, 0.0, 0.0, -1.0
]

uvs = [
  0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0,
  1.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0,
  1.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0,
  0.0, 1.0, 1.0
]

faces = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
  30, 31, 32, 33, 34, 35]

lines = [0, 1, 0, 2, 1, 2, 3, 4, 3, 5, 4, 5, 6, 7, 6, 8, 7, 8, 9, 10, 9, 11, 10, 11, 12, 13, 12, 14, 13, 14, 15, 16, 15,
  17, 16, 17, 18, 19, 18, 20, 19, 20, 21, 22, 21, 23, 22, 23, 24, 25, 24, 26, 25, 26, 27, 28, 27, 29, 28, 29, 30, 31,
  30, 32, 31, 32, 33, 34, 33, 35, 34, 35]

proj_mat = [
  0.9774190187454224, 0.0, 0.0, 0.0,
  0.0, 1.3032253980636597, 0.0, 0.0,
  0.0, 0.0, -1.0002000331878662, -1.0,
  0.0, 0.0, -0.20002000033855438, 0.0
]

view_mat = [
  1.0, 0.0, 0.0, 0.0,
  0.0, 1.0, 0.0, 0.0,
  0.0, 0.0, 1.0, 0.0,
  0.0, 0.0, -5.0, 1.0
]

model_view_mat = [
  1.0, 0.0, 0.0, 0.0,
  0.0, 1.0, 0.0, 0.0,
  0.0, 0.0, 1.0, 0.0,
  0.0, 0.0, -5.0, 1.0
]

normal_mat = [
  1.0, 0.0, 0.0,
  0.0, 1.0, 0.0,
  0.0, 0.0, 1.0
]

model_mat = [
  1.0, 0.0, 0.0, 0.0,
  0.0, 1.0, 0.0, 0.0,
  0.0, 0.0, 1.0, 0.0,
  0.0, 0.0, 0.0, 1.0
]

glfwInit

glfwWindowHint GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE
glfwWindowHint GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE
glfwWindowHint GLFW_CONTEXT_VERSION_MAJOR, 3
glfwWindowHint GLFW_CONTEXT_VERSION_MINOR, 3
glfwWindowHint GLFW_CONTEXT_REVISION, 0

window = glfwCreateWindow(800, 600, 'test', nil, nil)
glfwMakeContextCurrent window
glfwSwapInterval 1

glClearColor(0.0, 0.0, 0.0, 1.0)
glClearDepth(1)
glClearStencil(0)

glEnable(GL_DEPTH_TEST)
glDepthFunc(GL_LEQUAL)

glFrontFace(GL_CCW)
glCullFace(GL_BACK)
glEnable(GL_CULL_FACE)

glEnable(GL_BLEND)
glBlendEquation(GL_FUNC_ADD)
glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

width, height = ' '*8, ' '*8
 glfwGetFramebufferSize(window, width, height)
glViewport(0, 0, width.unpack('L')[0], height.unpack('L')[0])

vert_shader = glCreateShader GL_VERTEX_SHADER
vert_length = Fiddle::Pointer[vert.length]
glShaderSource vert_shader, 1, Fiddle::Pointer[vert].ref, vert_length.ref
glCompileShader vert_shader
shlog = shader_log vert_shader
raise "VERT:\n#{shlog}" unless shlog.nil? || shlog.empty?

frag_shader = glCreateShader GL_FRAGMENT_SHADER
frag_length = Fiddle::Pointer[frag.length]
glShaderSource frag_shader, 1, Fiddle::Pointer[frag].ref, frag_length.ref
glCompileShader frag_shader
shlog = shader_log frag_shader
raise "FRAG:\n#{shlog}" unless shlog.nil? || shlog.empty?

program = glCreateProgram

glAttachShader(program, vert_shader)
glAttachShader(program, frag_shader)

glLinkProgram(program)
glUseProgram(program)
prlog = program_log program
raise "PROG:\n#{prlog}" unless prlog.nil? || prlog.empty?

position_attr = glGetAttribLocation program, 'position'
color_attr = glGetAttribLocation program, 'color'

glUniformMatrix4fv glGetUniformLocation(program, 'modelMatrix'), 1, GL_FALSE, pointer(model_mat)
glUniformMatrix4fv glGetUniformLocation(program, 'viewMatrix'), 1, GL_FALSE, pointer(view_mat)
glUniformMatrix4fv glGetUniformLocation(program, 'modelViewMatrix'), 1, GL_FALSE, pointer(model_view_mat)
glUniformMatrix4fv glGetUniformLocation(program, 'projectionMatrix'), 1, GL_FALSE, pointer(proj_mat)
glUniformMatrix3fv glGetUniformLocation(program, 'normalMatrix'), 1, GL_FALSE, pointer(normal_mat)
glUniform3fv glGetUniformLocation(program, 'cameraPosition'), 1, pointer([0.0, 0.0, 0.0])
glUniform3fv glGetUniformLocation(program, 'diffuse'), 1, pointer([0.0, 1.0, 0.0])
glUniform1f glGetUniformLocation(program, 'opacity'), 1.0

vao = glCreateVertexArray
mesh_buffer = glCreateBuffer
color_buffer = glCreateBuffer
normals_buffer = glCreateBuffer
uvs_buffer = glCreateBuffer
faces_buffer = glCreateBuffer
lines_buffer = glCreateBuffer

glBindVertexArray vao

glBindBuffer(GL_ARRAY_BUFFER, mesh_buffer)
glBufferData_easy(GL_ARRAY_BUFFER, mesh, GL_DYNAMIC_DRAW)

glBindBuffer(GL_ARRAY_BUFFER, color_buffer)
glBufferData_easy(GL_ARRAY_BUFFER, color, GL_DYNAMIC_DRAW)

glBindBuffer(GL_ARRAY_BUFFER, normals_buffer)
glBufferData_easy(GL_ARRAY_BUFFER, normals, GL_DYNAMIC_DRAW)

glBindBuffer(GL_ARRAY_BUFFER, uvs_buffer)
glBufferData_easy(GL_ARRAY_BUFFER, uvs, GL_DYNAMIC_DRAW)

glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, faces_buffer)
glBufferData_easy(GL_ELEMENT_ARRAY_BUFFER, faces, GL_DYNAMIC_DRAW)

glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, lines_buffer)
glBufferData_easy(GL_ELEMENT_ARRAY_BUFFER, lines, GL_DYNAMIC_DRAW)

while glfwWindowShouldClose(window) == 0
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT)

  glBindVertexArray vao

  glBindBuffer(GL_ARRAY_BUFFER, mesh_buffer)
  glEnableVertexAttribArray position_attr
  glVertexAttribPointer position_attr, 3, GL_FLOAT, GL_FALSE, 0, 0

  glBindBuffer(GL_ARRAY_BUFFER, color_buffer)
  glEnableVertexAttribArray color_attr
  glVertexAttribPointer color_attr, 3, GL_FLOAT, GL_FALSE, 0, 0

  glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, faces_buffer)
  glDrawElements GL_TRIANGLES, faces.size, GL_UNSIGNED_INT, 0

  glfwSwapBuffers window
  glfwPollEvents
  break
end

glfwDestroyWindow window
glfwTerminate

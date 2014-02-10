require 'matrix'

include Math

Vector.class_eval do

  def x; self[0]; end
  def y; self[1]; end
  def z; self[2]; end
  def w; self[3]; end

  def r; self[0]; end
  def g; self[1]; end
  def b; self[2]; end
  def a; self[3]; end

  def s; self[0]; end
  def t; self[1]; end
  def p; self[2]; end
  def q; self[3]; end

  def cross(v)
    Vector.Raise ErrDimensionMismatch unless size == v.size && v.size == 3
    Vector[ v[1]*@elements[2] - v[2]*@elements[1],
            v[2]*@elements[0] - v[0]*@elements[2],
            v[0]*@elements[1] - v[1]*@elements[0] ]
  end
  def dot(v)
    Vector.Raise ErrDimensionMismatch if size != v.size

    p = 0
    each2(v) do |v1, v2|
      p += v1 * v2.conj
    end
    p
  end

end

module Matrices

  def to_radians a
    (a * Math::PI) / 180.0
  end

  def Matrices.translate m, v
    col3 = m.column(0)*v.x + m.column(1)*v.y + m.column(2)*v.w + m.column(3)
    Matrix.columns [ m.column(0), m.column(1), m.columns(2), col3 ]
  end

  def Matrices.rotate m, angle, v
    a = to_radians angle

    c = cos(a)
    s = sin(a)

    axis = v.normalize()

    temp = axis*(1.0-c)

    rot00 = c + temp.x * axis.x
    rot01 = 0 + temp.x * axis.y + s * axis.z
    rot02 = 0 + temp.x * axis.z - s * axis.y

    rot10 = 0 + temp.y * axis.x - s * axis.z
    rot11 = c + temp.y * axis.y
    rot12 = 0 + temp.y * axis.z + s * axis.x

    rot20 = 0 + temp.z * axis.x + s * axis.y
    rot21 = 0 + temp.z * axis.y - s * axis.x
    rot22 = c + temp.z * axis.z

    Matrix.columns([
      (m.column(0)*rot00) + (m.column(1)*rot01) + (m.column(2)*rot02),
      (m.column(0)*rot10) + (m.column(1)*rot11) + (m.column(2)*rot12),
      (m.column(0)*rot20) + (m.column(1)*rot21) + (m.column(2)*rot22),
      m.column(3)
    ])
  end

  def Matrices.scale m, v
    Matrix.columns([
      m.column(0)*(v.x),
      m.column(1)*(v.y),
      m.column(2)*(v.z),
      m.column(3)
    ])
  end

  def Matrices.perspective fovy, aspect, z_near, z_far
    half_fovy = to_radians(fovy*0.5)
    range = tan(half_fovy)
    left = -range * aspect
    right = range * aspect
    bottom = -range
    top = range

    Matrix.columns([
      [ (2.0 * z_near) / (right - left), 0.0, 0.0, 0.0 ],
      [ 0.0, (2.0 * z_near) / (top - bottom), 0.0, 0.0 ],
      [ 0.0, 0.0, -(z_far + z_near) / (z_far - z_near), -1.0 ],
      [ 0.0, 0.0, -(2.0 * z_far * z_near) / (z_far - z_near), 0.0 ]
    ])
  end

  def Matrices.frustum left, right, bottom, top, near, far
    m00 = (2.0 * near) / (right - left);
    m11 = (2.0 * near) / (top - bottom);
    m20 = (right + left) / (right - left);
    m21 = (top + bottom) / (top - bottom);
    m22 = -(far + near) / (far - near);
    m23 = -1.0;
    m32 = -(2.0 * far * near) / (far - near);

    Matrix.columns([
      [m00, 0.0, 0.0, 0.0],
      [0.0, m11, 0.0, 0.0],
      [m20, m21, m22, m23],
      [0.0, 0.0, m32, 0.0]
    ])
  end

  def Matrices.look_at eye, center, up
    f = (center - eye).normalize();
    u = up.normalize;
    s = f.cross(u).normalize;
    u = s.cross(f);

    Matrix.columns([
        [s.x, u.x, -f.x, 0.0],
        [s.y, u.y, -f.y, 0.0],
        [s.z, u.z, -f.z, 0.0],
        [-s.dot(eye), -u.dot(eye), f.dot(eye), 1.0]
    ])
  end

  def Matrices.ortho left, right, bottom, top, z_near, z_far
    m00 = 2.0 / (right - left)
    m11 = 2.0 / (top - bottom)
    m22 = -2.0 / (z_far - z_near)
    m30 = - (right + left) / (right - left)
    m31 = - (top + bottom) / (top - bottom)
    m32 = - (z_far + z_near) / (z_far - z_near)

    Matrix.columns([
        [ m00, 0.0, 0.0, 0.0 ],
        [ 0.0, m11, 0.0, 0.0 ],
        [ 0.0, 0.0, m22, 0.0 ],
        [ m30, m31, m32, 1.0 ]
    ])
  end

  def Matrices.ortho2d left, right, bottom, top
    m00 = 2.0 / (right - left)
    m11 = 2.0 / (top - bottom)
    m22 = -1.0
    m30 = - (right + left) / (right - left)
    m31 = - (top + bottom) / (top - bottom)

    Matrix.columns([
        [ m00, 0.0, 0.0, 0.0 ],
        [ 0.0, m11, 0.0, 0.0 ],
        [ 0.0, 0.0, m22, 0.0 ],
        [ m30, m31, 0.0, 1.0 ]
    ])
  end

end

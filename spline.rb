require_relative './gfx.rb'

class Spline

  def initialize control_points, degree=4
    @p = control_points
    @k = degree+1
    @t = (0..1).step( 1/(@p.size-1+@k).to_f ).to_a
  end

  def [](i); @p[i]; end
  def size; @p.size; end

  def p(t)
    sum = Vector.elements([0]*@p[0].size)
    (0...@p.size).each do |i|
      sum += @p[i] * n(i,@k,t)
    end
    sum
  end

  def n i, k, t
    if k == 1
      if t > @t[i] and t <= @t[i+1] then 1 else 0 end
    elsif k > 1
      ((t-@t[i]) / (@t[i+k-1]-@t[i])) * n(i,k-1,t) + ((@t[i+k] - t) / (@t[i+k]-@t[i+1])) * n(i+1,k-1,t)
    else
      raise "k must be positive"
    end
  end

  def sweep spline, tag, step=0.1
    mesh tag do
      (0..1).step(step) do |i|
        (0..1).step(step) do |j|
          pointv self.p(i) + spline.p(j)
          normal 0, 1, 0 # todo: work out normal
        end
      end
      (0..1/step-1).each do |i|
        (0..1/step-1).each do |j|
          a = 1/step*i + j
          b = a + 1
          c = a + 1/step
          d = c + 1
          face a, b, d
          face a, d, c
        end
      end
    end
  end

  def sweep_simple spline, tag
    mesh tag do
      (0...size).each do |i|
        (0...spline.size).each do |j|
          pointv self[i] + spline[j]
          normal 0, 1, 0 # todo: work out normal
        end
      end
      (0...size-1).each do |i|
        (0...spline.size-1).each do |j|
          a = spline.size*i + j
          b = a + 1
          c = a + spline.size
          d = c + 1
          face a, b, d
          face a, d, c
        end
      end
    end
  end

  def lathe tag, step=0.1, angle=360.0, axis=Vector[0,1,0]
    mesh tag do
      (0..1).step(step) do |i|
        (0..1).step(step) do |j|
          p = Matrices.rotate(Matrix.I(4), j*angle, axis) * self.p(i).to_pnt
          point p.x, p.y, p.z
          normal 0, 1, 0 # todo: work out normal
        end
      end
      (0..1/step-1).each do |i|
        (0..1/step-1).each do |j|
          a = 1/step*i + j
          b = a + 1
          c = a + 1/step
          d = c + 1
          face a, b, d
          face a, d, c
        end
      end
    end
  end

  def lathe_simple tag, step=0.1, angle=360.0, axis=Vector[0,1,0]
    mesh tag do
      (0...size).each do |i|
        (0..1).step(step) do |j|
          p = Matrices.rotate(Matrix.I(4), j*angle, axis) * self[i].to_pnt
          point p.x, p.y, p.z
          normal 0, 1, 0 # todo: work out normal
        end
      end
      (0...size-1).each do |i|
        (0..1/step-1).each do |j|
          a = 1/step*i + j
          b = a + 1
          c = a + 1/step
          d = c + 1
          face a, b, d
          face a, d, c
        end
      end
    end
  end

end

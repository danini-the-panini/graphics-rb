require 'docile'

module Spline

  @@splines = {}

  def splines; @@splines; end

  class Spline

    def initialize cp, degree=4, repeats
      @p = []
      repeats.each_index do |i|
        repeats[i].times { @p << cp[i] }
      end
      norms = []

      if size == 1
        norms << Vector[0,1,0]
      else
        norms[0] = normal_between cp[0], cp[1]
        (1...cp.size-1).each do |i|
          u = normal_between cp[i-1], cp[i]
          v = normal_between cp[i], cp[i+1]
          norms[i] = (u + v)*0.5
        end
        norms[cp.size-1] = normal_between cp[cp.size-2], cp[cp.size-1]
      end

      @normals = []
      repeats.each_index do |i|
        repeats[i].times { @normals << norms[i] }
      end

      @k = degree+1
      step = 1/(@p.size).to_f
      top = step * (@p.size+@k+1)
      @t = (0..top).step( step ).to_a
      @t_offset = @t[@k-1]
      @t_range = @t[@p.size+1] - @t_offset
    end

    def [](i); @p[i]; end
    def size; @p.size; end
    def each_control_point
      (0...size).each { |i| yield @p[i], @normals[i] }
      @p.each { |x| yield x }
    end

    def point(t)
      p t, @p
    end

    def normal(t)
      p t, @normals
    end

    def p(t, arr)
      t = t*@t_range + @t_offset
      sum = Vector.elements([0]*arr[0].size)
      (0...size).each do |i|
        sum += arr[i] * n(i,@k,t)
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

    def normal_between v, u
      s = u - v
      Vector[-s.y,s.x,0].normalize
    end
  end

  class SplineBuilder
    def initialize
      @control_points = []
      @repeats = []
      @degree = 4
    end
    def control_pointv(v, mult=1); @control_points << v; @repeats << mult; self; end
    def control_point(x,y,z, mult=1); control_pointv Vector[x,y,z], mult; self; end
    def degree(v); @degree = v; self; end
    def build
      Spline.new @control_points, @degree, @repeats
    end
  end

  def spline sym=nil, &block
    unless block_given?
      obj = splines[sym]
    else
      obj = Docile.dsl_eval(SplineBuilder.new, &block).build
      splines[sym] = obj unless sym.nil?
    end
    obj
  end
end

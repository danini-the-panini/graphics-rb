require 'docile'

module Spline

  @@splines = {}

  def splines; @@splines; end

  class Spline

    def initialize cp, degree=4
      @p = cp

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
      (0...size).each { |i| yield @p[i] }
    end

    # B-spline function, where @p is the array of control points,
    # t ∈ (0, 1) is position on the curve and n(i,k,t) is the basis function
    def p(t)
      t = t*@t_range + @t_offset
      sum = Vector.elements([0]*@p[0].size)
      (0...size).each do |i|
        sum += @p[i] * n(i,@k,t)
      end
      sum
    end

    # DeBoor-Cox basis function used in this implementation.
    def n(i, k, t)
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
      @degree = 4
    end
    def control_pointv(v, mult=1); mult.times { @control_points << v }; self; end
    def control_point(x,y,z, mult=1); control_pointv Vector[x,y,z], mult; self; end
    def degree(v); @degree = v; self; end
    def build
      Spline.new @control_points, @degree
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

require 'docile'

module Spline

  @@splines = {}

  def splines; @@splines; end

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
  end

  class SplineBuilder
    def initialize
      @control_points = []
      @degrees = 4
    end
    def control_pointv(v); @control_points << v; self; end
    def control_point(x,y,z); control_pointv Vector[x,y,z]; self; end
    def degrees(v); @degrees = v; self; end
    def build
      Spline.new @control_points, @degrees
    end
  end

  def spline sym=nil, &block
    unless block_given?
      splines[sym]
    else
      obj = Docile.dsl_eval(SplineBuilder.new, &block).build
      splines[sym] = obj unless sym.nil?
    end
    obj
  end
end

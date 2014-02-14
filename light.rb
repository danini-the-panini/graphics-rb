require 'docile'

module Light
  @@lights = {}

  def lights; @@lights; end

  class Light

    def initialize point
      @point = point
    end

    def point; @point; end

    def point=(v); @point = v; end

  end

  class LightBuilder
    def initialize
      @point = Vector[0,0,0]
    end
    def point(x,y,z); @point = Vector[x,y,z]; self; end
    def build
      Light.new @point
    end
  end

  def light sym=nil, &block
    unless block_given?
      lights[sym]
    else
      obj = Docile.dsl_eval(LightBuilder.new, &block).build
      lights[sym] = obj unless sym.nil?
      obj
    end
  end
end

require 'ray'

class Boid
  def initialize
    @shape = Ray::Polygon.circle([-10,-10], 5, [Ray::Color.red].sample)
    @shape.pos += [rand(1000), rand(1000)]

    @velocity = Ray::Vector2[rand(-5..5), rand(-5..5)]
  end

  def velocity=(pos)
    pos /= 2 while pos.distance([0,0]) > 10

    @velocity = pos
  end

  def pos
    shape.pos
  end

  def pos=(new_pos)
    if (0..1000).include?(new_pos.x) && (0..1000).include?(new_pos.y)
      shape.pos = new_pos
    else
      self.velocity *= -1
    end
  end

  attr_reader :velocity, :shape
end


Ray.game "Hello world!", :size => [1000,1000] do
  
  register { add_hook :quit, method(:exit!) }

  scene :square do
    @target = Ray::Vector2[0,0]

    boids     = 20.times.map { Boid.new }
    obstacles = 100.times.map { 
      Ray::Polygon.circle([-10,-10], 10, Ray::Color.yellow).tap do |c|
        c.pos += [rand(1000), rand(1000)]
      end
    }

    drawables = boids + obstacles


    rule1 = ->(boid) {
      delta = Ray::Vector2[0,0]

      (boids - [boid]).each { |b| delta += b.pos }
      
      delta /= boids.length - 1

      (delta - boid.pos) / 100
    }

    rule2 = ->(boid) {
      delta = Ray::Vector2[0,0]

      (drawables - [boid]).each do |b| 
        delta -= (b.pos - boid.pos) if b.pos.distance(boid.pos) < 30
      end

      delta / 100
    }

    rule3 = ->(boid) {
      delta = Ray::Vector2[0,0]

      (boids - [boid]).each do |b|
        delta += b.velocity
      end

      delta /= boids.length - 1

      (delta - boid.velocity) / 8
    }
    
    rule4 = ->(boid) { (@target - boid.pos) / 100.0 }

    always do 
      boids.each do |b| 
        b.velocity += rule1.(b) + rule2.(b)*10 + rule3.(b) + rule4.(b)
        b.pos      += b.velocity
      end

      obstacles.each do |b|
        b.pos += [rand(-1..2), rand(-1..2)]
      end
    end

    on(:mouse_motion) { |pos| @target = pos }

    render do |win|
      boids.each { |b| win.draw(b.shape) }
      obstacles.each { |b| win.draw(b) }
    end
  end

  scenes << :square
end

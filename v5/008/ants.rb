require 'ray'

class Cell
  def initialize(x, y)
    @shape = Ray::Polygon.rectangle([0,0,20,20], Ray::Color.white)
    
    @shape.outline  = Ray::Color.black
    @shape.outlined = true
    @shape.pos      = Ray::Vector2[x,y] * 20

    @pheremone      = 0
    @coords         = [x,y]
  end

  def add_pheremone
    @pheremone += 10

    gray = [255 - @pheremone, 0].max
    
    @shape.color = Ray::Color.new(gray, gray, gray)
  end

  def reduce_pheremone
    @pheremone = [@pheremone - 0.2, 0].max

    gray = [255 - @pheremone, 0].max
    
    @shape.color = Ray::Color.new(gray, gray, gray)
  end

  attr_reader :shape, :pheremone, :coords
end


Ant = Struct.new(:position, :carrying_food, :path)

class Grid
  def initialize(size)
    @size = size
    @grid = size.times.map do |x|
              size.times.map do |y|
                Cell.new(x,y)
              end
            end
  end

  def draw(window)
    @grid.each do |row|
      row.each { |cell| window.draw(cell.shape) }
    end
  end

  def [](x,y)
    @grid[x][y] 
  end
  
  def neighbors(x,y)
    cells = []

    positions = [[x-1, y-1], [x, y-1], [x+1, y-1],
                 [x-1, y  ],           [x+1, y  ],
                 [x-1, y+1], [x, y+1], [x+1, y+1]]

    positions.select { |x_,y_| (0...@size).include?(x_) && (0...@size).include?(y_) }
             .map    { |x_, y_| self[x_, y_] }
  end

  def best_path(x,y)
    nearby_values = neighbors(x,y).reduce(0) { |s,c| s + c.pheremone }
    randomizer    = rand(nearby_values)

    if nearby_values.zero? || rand < 0.5
      neighbors(x,y).sample
    else
      limit = 0

      neighbors(x,y).each do |n|
        if (limit .. limit + n.pheremone + 1).include?(randomizer)
          return n
        else
          limit += n.pheremone
        end
      end
    end
  end

  def each
    @grid.each { |a| a.each { |b| yield b } }
  end

  def sample
    @grid.sample.sample
  end
end
 


Ray.game "Hello world!", :size => [1000,1000] do
  register { add_hook :quit, method(:exit!) }

    table = Grid.new(20)

    scene :square do
      nest         = table.sample
      food_source  = table.sample

      ants = 5.times.map { Ant.new(nest.coords, false, []) }
      tick = 0

      always do
        ants.each do |ant|

          case ant.position
          when nest.coords
            ant.carrying_food = false
          when food_source.coords
            ant.carrying_food = true
          end

          table[*ant.position].add_pheremone
          
          if ant.carrying_food
            next_cell = table.best_path(*ant.position)
          else
            next_cell = table.neighbors(*ant.position).sample
          end

          ant.position = next_cell.coords
        end


        if tick % 2 == 0
          table.each { |cell| cell.reduce_pheremone }
        end

        tick += 1

        nest.shape.color         = Ray::Color.red
        food_source.shape.color  = Ray::Color.blue
      end

      render do |win|
        table.draw(win)

        ants.each do |ant|
          circle = Ray::Polygon.circle([-10, -10], 5, Ray::Color.black)
          circle.pos = Ray::Vector2[*ant.position]*20

          win.draw(circle)
        end
      end
    end

  scenes << :square
end

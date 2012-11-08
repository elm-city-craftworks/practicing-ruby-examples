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
    @pheremone += 50

    gray = [255 - @pheremone, 0].max
    
    @shape.color = Ray::Color.new(gray, gray, gray)
  end

  def reduce_pheremone
    @pheremone -= 5

    gray = [255 - @pheremone, 0].max
    
    @shape.color = Ray::Color.new(gray, gray, gray)
  end

  attr_reader :shape, :pheremone, :coords
end

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

    if nearby_values.zero? || rand < 0.1
      neighbors(x,y).sample
    else
      limit = 0

      neighbors(x,y).each do |n|
        if (limit .. limit + n.pheremone).include?(randomizer)
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

    table = Grid.new(50)

    scene :square do
      coords = 5.times.map { table.sample.coords }
      tick   = 0

      always do
        coords = coords.map do |c|
          if tick < 1000
            next_cell = table.neighbors(*c).sample
            next_cell.add_pheremone

            next_cell.coords
          else
            next_cell = table.best_path(*c)
            next_cell.add_pheremone

            next_cell.coords
          end
        end

        if tick % 10 == 0
          table.each { |cell| cell.reduce_pheremone }
        end

        tick += 1
      end

      render do |win|
        table.draw(win)
      end
    end

  scenes << :square
end

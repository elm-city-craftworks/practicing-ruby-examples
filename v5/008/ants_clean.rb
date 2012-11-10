require "ray"

class Ant
  def initialize(position)
    @history  = []
    @position = position
    @carrying = false
  end

  attr_reader :position, :history
  attr_accessor :carrying

  def move(new_position)
    return false if Array(@history[-20..-1]).include?([@position, new_position])

    @history << [@position, new_position]
    @position = new_position

    true
  end
end

class Cell
  def initialize(x, y)
    @shape = Ray::Polygon.rectangle([0,0,20,20], Ray::Color.white)
    
    @shape.outline  = Ray::Color.black
    @shape.outlined = true
    @shape.pos      = Ray::Vector2[x,y] * 20

    @pheremone      = 0.0
    @coords         = [x,y]
  end

  def add_pheremone
    @pheremone = [@pheremone + 100, 255].min
    
    gray = [@pheremone, 30].max
    
    @shape.color = Ray::Color.new(gray, gray, gray)
  end

  def reduce_pheremone
    @pheremone = [@pheremone * 0.995, 0].max

    gray = [@pheremone, 30].max
    
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
      row.each { |cell| window.draw(cell.shape) if cell.pheremone > 1 }
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

    if nearby_values.zero? || rand < 0.05
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

      neighbors(x,y).last
    end
  end

  def each
    @grid.each { |a| a.each { |b| yield b } }
  end

  def sample
    @grid.sample.sample
  end
end


Ray.game "Ants", :size => [800,800] do
  register { add_hook :quit, method(:exit!) }

  table = Grid.new(40)

  home = table.sample
  goals = 5.times.map { table.sample }

  ants = 20.times.map { Ant.new(home.coords) }
  tick = 0

  scene :main do
    always do
      ants.each do |ant|
        if ant.position == home.coords
          if ant.carrying
            ant.history.flatten(1).uniq.each do |pos|
              table[*pos].add_pheremone
            end
          end

          ant.carrying = false

          ant.history.clear
        end

        if goals.any? { |g| g.coords == ant.position }
          ant.carrying = true
        end

        next_cell = table.best_path(*ant.position)

        ant.move(next_cell.coords) 
      end

      if tick % 2 == 0
        table.each { |cell| cell.reduce_pheremone }
      end

      tick += 1

      home.shape.color  = Ray::Color.red
      goals.each { |g| g.shape.color  = Ray::Color.blue }

    end

     render do |win|
      table.draw(win)

      ants.each do |ant|
        color = ant.carrying ? Ray::Color.fuschia : Ray::Color.green

        circle = Ray::Polygon.circle([-10, -10], 5, color)
        circle.pos = Ray::Vector2[*ant.position]*20

        win.draw(circle)
        win.draw(home.shape)
        goals.each { |g| win.draw(g.shape) }
      end
    end
  end

  scenes << :main
end


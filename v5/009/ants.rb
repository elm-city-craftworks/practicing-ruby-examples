class Cell
  def initialize(food, pheremone)
    @food, @pheremone = food, pheremone
  end

  attr_accessor :food, :pheremone, :ant, :home
end

class Ant
  def initialize(direction)
    @direction = direction
  end

  attr_accessor :food, :direction
end

class World
  def initialize(size)
    @data = size.times.map { size.times.map { Cell.new(0,0) } }
  end

  def [](location)
    x,y = location

    @data[x][y]
  end

  attr_reader :data
end

class Simulator
  DIMENSIONS  = 80
  FOOD_PLACES = 35
  FOOD_RANGE  = 100
  HOME_OFFSET = DIMENSIONS / 4
  NANTS_SQRT  = 7
  HOME_RANGE  = HOME_OFFSET ... HOME_OFFSET + NANTS_SQRT
  DIR_DELTA   = [ [0, -1], [ 1, -1], [ 1, 0], [ 1,  1],
                  [0,  1], [-1,  1], [-1, 0], [-1, -1] ]

  EVAP_RATE   = 0.99

  def initialize
    @world          = World.new(80)
    @ant_locations  = {}

    FOOD_PLACES.times do
      @world[[rand(DIMENSIONS), rand(DIMENSIONS)]].food = rand(FOOD_RANGE)
    end

    HOME_RANGE.to_a.product(HOME_RANGE.to_a).map do |x,y|
      ant = Ant.new(rand(8))
     
      @world[[x,y]].home = true
      @world[[x,y]].ant  = ant

      @ant_locations[ant] = [x,y]
    end
  end

  attr_reader :world
  
  def wrand(slices)
    total = slices.reduce(:+)
    r     = rand(total)

    sum   = 0

    slices.each_with_index do |e,i|
      return i if r < sum + e
      
      sum  += e
    end
  end

  def delta_loc(loc, dir)
    x,y =     loc

    dx, dy = DIR_DELTA[dir % 8]

    [(x + dx) % DIMENSIONS, (y + dy) % DIMENSIONS]
  end

  def turn(loc, amt)
    cell = @world[loc]
    ant  = cell.ant

    ant.direction = (ant.direction + amt) % 8

    loc
  end

  def move(loc)
    old_cell = @world[loc]
    ant      = old_cell.ant

    new_loc  = delta_loc(loc, ant.direction)
    new_cell = @world[new_loc]

    new_cell.ant = ant
    old_cell.ant = nil

    @ant_locations[ant] = new_loc

    old_cell.pheremone += 1 unless old_cell.home

    new_loc
  end

  def take_food(loc)
    cell = @world[loc]
    ant  = cell.ant

    cell.food -= 1
    ant.food   = true

    loc
  end

  def drop_food(loc)
    cell = @world[loc]
    ant  = cell.ant

    cell.food += 1
    ant.food   = false

    loc
  end

  def evaporate
    (DIMENSIONS.times.to_a).product(DIMENSIONS.times.to_a) do |loc|
      cell = @world[loc]

      cell.pheremone *= EVAP_RATE
    end
  end

  def rank_by(xs, &keyfn)
    sorted = xs.sort_by { |e| keyfn.(e).to_f }

    (0...sorted.length).each_with_object(Hash.new { |h,k| h[k] = 0 }) do |i,r|
      r[sorted[i]] = i + 1
    end
  end

end

sim = Simulator.new

p sim.world[[20,20]]
p sim.move([20,20])

p sim.evaporate

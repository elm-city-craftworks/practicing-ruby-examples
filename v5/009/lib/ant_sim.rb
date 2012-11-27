#srand(54321)

module AntSim
  class Ant
    def initialize(direction, location)
      self.direction = direction
      self.location  = location
    end

    attr_accessor :food, :direction, :location
  end

  class Cell
    def initialize(food, home_pheremone, food_pheremone)
      self.food = food 
      self.home_pheremone = home_pheremone
      self.food_pheremone = food_pheremone
    end

    attr_accessor :food, :home_pheremone, :food_pheremone, :ant, :home
  end

  class World
    def initialize(world_size)
      self.size = world_size
      self.data = size.times.map { size.times.map { Cell.new(0,0,0) } }
    end

    attr_reader :size

    def [](location)
      x,y = location

      data[x][y]
    end

    def sample
      data[rand(size)][rand(size)]
    end

    def each
      data.each_with_index do |col,x| 
        col.each_with_index do |cell, y| 
          yield [cell, [x, y]]
        end
      end
    end

    private

    attr_accessor :data
    attr_writer   :size
  end

  require "set"

  class Actor
    DIR_DELTA   = [ [0, -1], [ 1, -1], [ 1, 0], [ 1,  1],
                    [0,  1], [-1,  1], [-1, 0], [-1, -1] ]

    def initialize(world, ant)
      self.world   = world
      self.ant     = ant

      self.history = Set.new
    end

    attr_reader :ant

    def mark_food_trail
      history.each do |old_cell|
        old_cell.food_pheremone += 1 unless old_cell.food > 0 
      end

      history.clear

      self
    end

    def mark_home_trail
      history.each do |old_cell|
        old_cell.home_pheremone += 1 unless old_cell.home
      end

      history.clear

      self
    end

    def drop_food
      here.food += 1
      ant.food   = false

      self
    end

    def take_food
      here.food -= 1
      ant.food   = true

      self
    end

    def turn(amt)
      ant.direction = (ant.direction + amt) % 8

      self
    end

    def move
      history << here

      new_location = neighbor(ant.direction)

      ahead.ant = ant
      here.ant  = nil

      ant.location = new_location

      self
    end

    def here
      world[ant.location]
    end

    def ahead
      world[neighbor(ant.direction)]
    end

    def ahead_left
      world[neighbor(ant.direction - 1)]
    end

    def ahead_right
      world[neighbor(ant.direction + 1)]
    end
    
    def nearby_places
      [ahead, ahead_left, ahead_right]
    end

    private

    def neighbor(direction)
      x,y = ant.location

      dx, dy = DIR_DELTA[direction % 8]

      [(x + dx) % world.size, (y + dy) % world.size]
    end

    attr_accessor :world, :history
    attr_writer   :ant
  end

  class Simulator
    DIMENSIONS  = 80
    FOOD_PLACES = 35
    FOOD_RANGE  = 50
    HOME_OFFSET = DIMENSIONS / 4
    NANTS_SQRT  = 7
    HOME_RANGE  = HOME_OFFSET ... HOME_OFFSET + NANTS_SQRT

    EVAP_RATE    = 0.95
    ANT_SLEEP    = 0.005

    def initialize
      self.world  = World.new(DIMENSIONS)
      self.actors = []

      FOOD_PLACES.times do
        world.sample.food = FOOD_RANGE
      end

      HOME_RANGE.to_a.product(HOME_RANGE.to_a).map do |x,y|
        ant = Ant.new(rand(8), [x,y])
       
        world[[x,y]].home = true
        world[[x,y]].ant  = ant

        actors << Actor.new(world, ant)
      end
    end

    attr_reader :world, :actors

    def iterate
      actors.each do |actor|
        optimizer = Optimizer.new(actor.here, actor.nearby_places)
        action    = actor.ant.food ? optimizer.seek_home : optimizer.seek_food

        case action
        when :drop_food
          actor.drop_food.mark_food_trail.turn(4)
        when :take_food
          actor.take_food.mark_home_trail.turn(4)
        when :move_forward
          actor.move
        when :turn_left
          actor.turn(-1)
        when :turn_right
          actor.turn(1)
        else
          raise NotImplementedError, action.inspect
        end
      end

      sleep ANT_SLEEP
    end

    def evaporate
      world.each do |cell, (x,y)| 
        cell.home_pheremone *= EVAP_RATE 
        cell.food_pheremone *= EVAP_RATE
      end
    end

    private

    attr_writer :world, :actors
  end

  require "forwardable"

  class Optimizer
    BEST_CHOICE_BONUS = 3

    extend Forwardable

    def initialize(here, nearby_places)
      self.here          = here
      self.nearby_places = nearby_places

      self.ahead, self.ahead_left, self.ahead_right = nearby_places
    end

    attr_reader :here, :nearby_places, :ahead, :ahead_left, :ahead_right

    def seek_home
      if here.home
        :drop_food
      elsif ahead.home && (! ahead.ant)
        :move_forward
      else
        home_ranking = rank_by { |cell| cell.home ? 1 : 0 }
        pher_ranking = rank_by { |cell| cell.home_pheremone }

        ranks = combined_ranks(home_ranking, pher_ranking)
        follow_trail(ranks)
      end
    end

    def seek_food
      if here.food > 0 && (! here.home)
        :take_food
      elsif ahead.food > 0 && (! ahead.home ) && (! ahead.ant )
        :move_forward
      else
        food_ranking = rank_by { |cell| cell.food }
        pher_ranking = rank_by { |cell| cell.food_pheremone }

        ranks = combined_ranks(food_ranking, pher_ranking)
        follow_trail(ranks)
      end
    end

    private

    attr_writer :here, :nearby_places, :ahead, :ahead_left, :ahead_right

    def follow_trail(ranks)
      choice = wrand([ ahead.ant ? 0 : ranks[ahead],
                       ranks[ahead_left],
                       ranks[ahead_right]])

      [:move_forward, :turn_left, :turn_right][choice]
    end
    
    def combined_ranks(a,b)
      combined = a.merge(b) { |k,v|  a[k] + b[k] }
      top_k, _ = combined.max_by { |k,v| v }

      combined[top_k] *= BEST_CHOICE_BONUS

      combined
    end

    def rank_by(&keyfn)
      ranks  = Hash.new { |h,k| h[k] = 0 }
      sorted = nearby_places.sort_by { |e| keyfn.call(e).to_f }

      (0...sorted.length).each { |i| ranks[sorted[i]] = i + 1 }

      ranks
    end

    def wrand(slices)
      total = slices.reduce(:+)
      r     = rand(total)

      sum   = 0

      slices.each_with_index do |e,i|
        return i if r < sum + e
        
        sum  += e
      end
    end
  end

  class Visualization
    include Java

    import java.awt.Color
    import java.awt.Graphics
    import java.awt.BasicStroke
    import java.awt.Dimension

    import java.awt.image.BufferedImage
    import javax.swing.JPanel
    import javax.swing.JFrame


    SCALE           = 10
    PHEREMONE_SCALE = 10.0
    FOOD_SCALE      = 30.0

    def self.run
      new.run
    end

    def run
      sim = Simulator.new
      ui  = self

      food_cells = []

      sim.world.each do |cell, (x,y)|
        food_cells << [[x,y], cell] if cell.food > 0
      end

      panel = Class.new(JPanel) { 
        define_method(:paint) { |g| ui.render(g, sim) }
      }.new 
      
      panel.setPreferredSize(Dimension.new(SCALE * Simulator::DIMENSIONS,
                                           SCALE * Simulator::DIMENSIONS))
      frame = JFrame.new
      frame.add(panel)
      frame.pack
      frame.show

      t = Time.now

      loop do
        if Time.now - t > 0.2
          sim.evaporate
          t = Time.now
        end

        sim.iterate

        panel.repaint
      end
    end

    def fill_cell(g, x, y, c)
      g.setColor(c)
      g.fillRect(x * SCALE, y * SCALE, SCALE, SCALE)
    end

    def render_ant(ant, g, x, y)
      black = Color.new(0,0,0,255).getRGB
      gray  = Color.new(100,100,100,255).getRGB
      red   = Color.new(255,  0,  0,255).getRGB

      hx, hy, tx, ty = [[2, 0, 2, 4], [4, 0, 0, 4], [4, 2, 0, 2], [4, 4, 0, 0],
                        [2, 4, 2, 0], [0, 4, 4, 0], [0, 2, 4, 2], [0, 0, 4, 4]][ant.direction]

      g.setStroke(BasicStroke.new(3))
      g.setColor(ant.food ? Color.new(255, 0, 0, 255) : Color.new(0, 0, 0, 255))
      g.drawLine(hx + x * SCALE, hy + y * SCALE, tx + x * SCALE, ty + y * SCALE)
    end

    def render_place(g, cell, x, y)
      if cell.food_pheremone > 0
        fill_cell(g, x, y, Color.new(0,0,255, [255 * (cell.food_pheremone / PHEREMONE_SCALE), 255].min.to_i))
      elsif cell.home_pheremone > 0
        fill_cell(g, x, y, Color.new(0, 255, 0, [255 * (cell.home_pheremone / PHEREMONE_SCALE), 255].min.to_i))
      end

      if cell.food > 0
        fill_cell(g, x, y, Color.new(255, 0, 0, [255 * (cell.food / FOOD_SCALE), 255].min.to_i))
      end

      if cell.ant
        render_ant(cell.ant, g, x, y)
      end
    end

    def render(g, sim)
      dim = Simulator::DIMENSIONS

      img = BufferedImage.new(SCALE * dim, 
                              SCALE * dim,
                              BufferedImage::TYPE_INT_ARGB)

      bg  = img.getGraphics

      bg.setColor(Color.white)
      bg.fillRect(0,0, img.getWidth, img.getHeight)

      sim.world.each do |cell, (x,y)|
        render_place(bg, cell, x, y)
      end

      bg.setColor(Color.blue)
      bg.drawRect(SCALE * Simulator::HOME_OFFSET, SCALE * Simulator::HOME_OFFSET,
                  SCALE * Simulator::NANTS_SQRT,  SCALE * Simulator::NANTS_SQRT)

      g.drawImage(img, 0, 0, nil)
      bg.dispose
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  AntSim::Visualization.run
end

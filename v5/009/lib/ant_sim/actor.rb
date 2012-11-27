require "set"

module AntSim
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
end

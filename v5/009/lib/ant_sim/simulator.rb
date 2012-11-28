module AntSim
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
        
        if actor.foraging?
          action = optimizer.seek_food
        else
          action = optimizer.seek_home
        end

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
end

module AntSim
  class Ant
    def initialize(direction, location)
      self.direction = direction
      self.location  = location
    end

    attr_accessor :food, :direction, :location
  end
end

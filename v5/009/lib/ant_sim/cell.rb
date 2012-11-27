module AntSim
  class Cell
    def initialize(food, home_pheremone, food_pheremone)
      self.food = food 
      self.home_pheremone = home_pheremone
      self.food_pheremone = food_pheremone
    end

    attr_accessor :food, :home_pheremone, :food_pheremone, :ant, :home
  end
end

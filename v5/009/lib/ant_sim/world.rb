module AntSim
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
end

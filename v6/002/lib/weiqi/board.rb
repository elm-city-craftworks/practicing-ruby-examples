module Weiqi
  class Board
    def initialize(black_stones, white_stones)
      @black_stones = black_stones
      @white_stones = white_stones
    end

    attr_accessor :black_stones, :white_stones
  end
end

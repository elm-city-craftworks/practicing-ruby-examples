module Weiqi
  class Game
    def initialize(engine)
      @engine    = engine
      @observers = []
    end

    def observe(&block)
      @observers << block
    end

    def move(x, y)
      board = @engine.play_black(x, y)
      @observers.each { |o| o.(board) }

      Thread.new do
        board = @engine.play_white
        @observers.each { |o| o.(board) }
      end
    end

    def quit
      @engine.quit
    end
  end
end

require "tmpdir"
require "sgf"
require "socket"

require_relative "board"


module Weiqi
  class GnuGo
    HOST       = "localhost"
    PORT       = 9000
    BOARD_SIZE = 5

    def self.start_server
      Thread.new do
        system("gnugo --gtp-listen #{PORT} --mode gtp --boardsize #{BOARD_SIZE}")
      end

      sleep 2
    end

    def initialize
      @history = []
    end

    def play_black(x, y)
      if (0..BOARD_SIZE).include?(x) && (0..BOARD_SIZE).include?(y)
        coords = go_coords(x, y)
        @history << coords

        command("play B #{coords}")
        update_board
      else
        @history << "PASS"
        command("play B PASS")
        update_board
      end
    end

    def play_white
      @history << command("genmove W")[2..-2]
      update_board
    end

    def quit
      command("quit")
    end

    def update_board
      p @history

      if @history.last(2) == ["PASS", "PASS"]
        command("final_score")
        quit
        exit!
      else
        Dir.mktmpdir do |dir|
          command("printsgf #{dir}/foo.sgf")

          parser = SGF::Parser.new
          game   = parser.parse("#{dir}/foo.sgf").games.first

          node   = game.current_node

          black_stones = (node[:AB] || []).map { |coord| cartesian_coords(coord) }
          white_stones = (node[:AW] || []).map { |coord| cartesian_coords(coord) }
        
          Board.new(black_stones, white_stones)
        end
      end
    end
    
    private

    def go_coords(x,y)
      "#{(("A".."Z").to_a - ["I"])[x]}#{BOARD_SIZE - y}"
    end

    def cartesian_coords(coord)
      alpha = ("a".."z").to_a
      [alpha.index(coord[0]), alpha.index(coord[1])]
    end

    def socket
      @socket ||= TCPSocket.new(HOST, PORT)
    end

    def command(msg)
      STDERR.puts("COMMAND: #{msg}")
      socket.puts(msg)

      buffer = ""
      until (line = socket.gets) == "\n"
        buffer << line
      end

      STDERR.puts("RESPONSE: #{buffer}")
      
      buffer
    end
  end
end


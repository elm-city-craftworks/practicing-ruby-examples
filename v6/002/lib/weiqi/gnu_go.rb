require "tmpdir"
require "sgf"
require "socket"

require_relative "board"


module Weiqi
  class GnuGo
    HOST = "localhost"
    PORT = 9001

    def self.start_server
      Thread.new do
        system("gnugo --gtp-listen #{PORT} --mode gtp")
      end

      sleep 2
    end

    def play_black(x, y)
      coords = go_coords(x, y)

      command("play B #{coords}")
      update_board
    end

    def play_white
      command("genmove W")
      update_board
    end

    def quit
      command("quit")
    end

    def update_board
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
    
    private

    def go_coords(x,y)
      "#{(("A".."Z").to_a - ["I"])[x]}#{19 - y}"
    end

    def cartesian_coords(coord)
      alpha = ("a".."z").to_a
      [alpha.index(coord[0]), alpha.index(coord[1])]
    end

    def socket
      @socket ||= TCPSocket.new(HOST, PORT)
    end

    def command(msg)
      socket.puts(msg)

      buffer = ""
      until (line = socket.gets) == "\n"
        buffer << line
      end
      
      buffer
    end
  end
end


require "socket"
require "tmpdir"
require "sgf"


module Weiqi
  class Board
    def initialize(black_stones, white_stones)
      @black_stones = black_stones
      @white_stones = white_stones
    end

    attr_accessor :black_stones, :white_stones
  end

  class GnuGo
    HOST = "localhost"
    PORT = 9000

    def self.start_server
      Thread.new do
        system("gnugo --gtp-listen 9000 --mode gtp")
      end

      sleep 1
    end

    def play_black(x, y)
      coords = board_position(x, y)

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


        alpha = ("a".."z").to_a

        black_stones = (node[:AB] || []).map { |coord| [alpha.index(coord[0]), alpha.index(coord[1])] }
        white_stones = (node[:AW] || []).map { |coord| [alpha.index(coord[0]), alpha.index(coord[1])] }
      
        Board.new(black_stones, white_stones)
      end
    end
    
    private

    def board_position(x,y)
      "#{(("A".."Z").to_a - ["I"])[x]}#{19 - y}"
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

Weiqi::GnuGo.start_server


gnugo = Weiqi::GnuGo.new
p gnugo.play_black(3,3)
p gnugo.play_white
p gnugo.play_black(3,4)
p gnugo.play_white

gnugo.quit

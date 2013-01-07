require "socket"
require "net/telnet"

module Weiqi

  class UI
    include Java

    import java.awt.Color
    import java.awt.Graphics
    import java.awt.BasicStroke
    import java.awt.Dimension
    import java.awt.geom.Ellipse2D;
    import java.awt.event.MouseAdapter

    import java.awt.image.BufferedImage
    import javax.swing.JPanel
    import javax.swing.JFrame

    class MoveListener < MouseAdapter
      attr_accessor :game

      # http://stackoverflow.com/questions/3382330/mouselistener-for-jpanel-missing-mouseclicked-events
      def mouseReleased(event)
        game.move(((event.getX - 125) / 30.0).round, ((event.getY - 125) / 30.0).round)
      end
    end

    require "tempfile"

    class Game 
      def initialize(&observer)
        @observer = observer
      end

      def socket
        @socket ||= TCPSocket.new("localhost", 9000)
      end

      def move(x,y)
        coord = "#{(("A".."Z").to_a - ["I"])[x]}#{19 - y}"

        command("play B #{coord}")
        update_board

        Thread.new do
          command("genmove W")
          update_board
        end
      end

      def update_board
        Dir.mktmpdir do |dir|
          command("printsgf #{dir}/foo.sgf")

          parser = SGF::Parser.new
          game   = parser.parse("#{dir}/foo.sgf").games.first

          node   = game.current_node


          alpha = ("a".."z").to_a

          white_stones = (node[:AW] || []).map { |coord| [alpha.index(coord[0]), alpha.index(coord[1])] }
          black_stones = (node[:AB] || []).map { |coord| [alpha.index(coord[0]), alpha.index(coord[1])] }
          
          @observer.call(white_stones, black_stones)
        end
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

    class Panel < JPanel
      attr_accessor :white_stones, :black_stones

      def paintComponent(g)
        image = BufferedImage.new(800,800, BufferedImage::TYPE_INT_ARGB)

        bg = image.getGraphics
        
        bg.setColor(Color.new(222, 184, 135, 255))
        bg.fillRect(0,0,image.getWidth, image.getHeight)

        18.times.to_a.product(18.times.to_a) do |x,y|
          bg.setColor(Color.new(255, 250, 240, 255))
          bg.fillRect(125+x*30,125+y*30,30,30)
          bg.setColor(Color.black)
          bg.setStroke(BasicStroke.new(1))
          bg.drawRect(125+x*30,125+y*30,30,30)
        end

        bg.setColor(Color.black)
        bg.fillArc(120+30*3, 120+30*3, 10, 10, 0, 360)
        bg.fillArc(120+30*3, 120+30*9, 10, 10, 0, 360)
        bg.fillArc(120+30*3, 120+30*15, 10, 10, 0, 360)

        bg.fillArc(120+30*9, 120+30*3, 10, 10, 0, 360)
        bg.fillArc(120+30*9, 120+30*9, 10, 10, 0, 360)
        bg.fillArc(120+30*9, 120+30*15, 10, 10, 0, 360)

        bg.fillArc(120+30*15, 120+30*3, 10, 10, 0, 360)
        bg.fillArc(120+30*15, 120+30*9, 10, 10, 0, 360)
        bg.fillArc(120+30*15, 120+30*15, 10, 10, 0, 360)

        white_stones.each do |x,y|
          bg.setColor(Color.white)
          bg.fillArc(110+30*x, 110+30*y, 30, 30, 0, 360)
          bg.setColor(Color.black)
          bg.drawArc(110+30*x, 110+30*y, 30, 30, 0, 360)
        end

        black_stones.each do |x,y|
          bg.setColor(Color.black)
          bg.fillArc(110+30*x, 110+30*y, 30, 30, 0, 360)
        end

        g.drawImage(image, 0, 0, nil)
        bg.dispose
      end
    end

    def self.run
      panel = Panel.new
      panel.setPreferredSize(Dimension.new(800, 800))

      # FIXME: Ugly
      panel.white_stones = []
      panel.black_stones = []

      frame = JFrame.new
      frame.add(panel)
      frame.pack
      frame.show

      move_listener = MoveListener.new

      game = Game.new do |white_stones, black_stones| 
               panel.white_stones = white_stones
               panel.black_stones = black_stones
               panel.repaint
             end
               
      move_listener.game = game
      
      panel.addMouseListener(move_listener)
    end
  end
end



#sgf = File.read("foo.sgf")
  
#sgf[/AB((\[\w\w\])+)/].scan(/\[(\w\w)\]/).flatten.map { |e| [("a".."z").to_a.index(e.chars.to_a.first), ("a".."z").to_a.index(e.chars.to_a.last)] }


require "sgf"



#Thread.new { system("gnugo --gtp-listen 9999 --mode gtp") }

Weiqi::UI.run

#require "net/telnet"

# You can simplify this by using SGFParser gem...
# 
# 

=begin




gnugo.cmd("showboard") { |c| print c }

gnugo.cmd("genmove B") 
gnugo.cmd("genmove W") 
gnugo.cmd("play B E6") 
gnugo.cmd("showboard") { |c| print c }
=end

=begin
require "open3"


class GnuGo
  def initialize
    @input, @output, _, _ = Open3.popen3("gnugo --mode gtp")
  end

  def run(command)
    @input.puts(command)
    read_response(@output)
  end

  private

  def read_response(io)
    buffer = ""

    until (line = io.gets) == "\n"
      buffer << line
    end

    buffer
  end
end

require 'ray'

Ray.game("Hello world!", :size => [800, 600]) do
  players = ["B", "W"].cycle
  gnugo = GnuGo.new

  register { add_hook :quit, method(:exit!) }

   

  scene :hello do
    message = ""

    on :key_press, key(:a) do
      player  = players.next
      message = "#{player} #{gnugo.run("genmove #{player}")}"
    end

    on :key_press, key(:b) do
      message = gnugo.run("showboard")
    end
   
    render do |win| 
      label = text(message, :at => [100, 100], :size => 14, :font => "VeraMono.ttf")
      win.draw label
    end
  end

  scenes << :hello
end
=end

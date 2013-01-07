module Weiqi
  class UI
    include Java
    import java.awt.Color
    import java.awt.Graphics
    import java.awt.BasicStroke
    import java.awt.Dimension

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

    class Panel < JPanel
      def board
        @board ||= Board.new([],[])
      end

      attr_writer :board

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

        board.white_stones.each do |x,y|
          bg.setColor(Color.white)
          bg.fillArc(110+30*x, 110+30*y, 30, 30, 0, 360)
          bg.setColor(Color.black)
          bg.drawArc(110+30*x, 110+30*y, 30, 30, 0, 360)
        end

        board.black_stones.each do |x,y|
          bg.setColor(Color.black)
          bg.fillArc(110+30*x, 110+30*y, 30, 30, 0, 360)
        end

        g.drawImage(image, 0, 0, nil)
        bg.dispose
      end
    end

    def self.run(game)
      panel = Panel.new
      panel.setPreferredSize(Dimension.new(800, 800))

      frame = JFrame.new
      frame.add(panel)
      frame.pack
      frame.show

      move_listener      = MoveListener.new
      move_listener.game = game

      game.observe do |board| 
        panel.board = board 
        panel.repaint
      end
      
      panel.addMouseListener(move_listener)
    end
  end
end

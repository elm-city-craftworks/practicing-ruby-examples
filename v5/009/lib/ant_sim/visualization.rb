module AntSim
  class Visualization
    include Java

    import java.awt.Color
    import java.awt.Graphics
    import java.awt.BasicStroke
    import java.awt.Dimension

    import java.awt.image.BufferedImage
    import javax.swing.JPanel
    import javax.swing.JFrame

    class Panel < JPanel
      attr_accessor :interface, :simulator

      def paint(g)
        interface.render(g, simulator)
      end
    end

    SCALE              = 10
    PHEREMONE_SCALE    = 10.0
    FOOD_SCALE         = 30.0
    EVAPORATION_DELAY  = 0.2

    def self.run
      new.run
    end

    def run
      sim = Simulator.new
      ui  = self

      food_cells = []

      sim.world.each do |cell, (x,y)|
        food_cells << [[x,y], cell] if cell.food > 0
      end

      panel = Panel.new
      panel.simulator = sim
      panel.interface = ui
      
      panel.setPreferredSize(Dimension.new(SCALE * Simulator::DIMENSIONS,
                                           SCALE * Simulator::DIMENSIONS))
      frame = JFrame.new
      frame.add(panel)
      frame.pack
      frame.show

      t = Time.now

      loop do
        if Time.now - t > EVAPORATION_DELAY
          sim.evaporate
          t = Time.now
        end

        sim.iterate

        panel.repaint
      end
    end

    def fill_cell(g, x, y, c)
      g.setColor(c)
      g.fillRect(x * SCALE, y * SCALE, SCALE, SCALE)
    end

    def render_ant(ant, g, x, y)
      black = Color.new(0,0,0,255).getRGB
      gray  = Color.new(100,100,100,255).getRGB
      red   = Color.new(255,  0,  0,255).getRGB

      hx, hy, tx, ty = [[2, 0, 2, 4], [4, 0, 0, 4], [4, 2, 0, 2], [4, 4, 0, 0],
                        [2, 4, 2, 0], [0, 4, 4, 0], [0, 2, 4, 2], [0, 0, 4, 4]][ant.direction]

      g.setStroke(BasicStroke.new(3))
      g.setColor(ant.food ? Color.new(255, 0, 0, 255) : Color.new(0, 0, 0, 255))
      g.drawLine(hx + x * SCALE, hy + y * SCALE, tx + x * SCALE, ty + y * SCALE)
    end

    def render_place(g, cell, x, y)
      if cell.food_pheremone > 0
        fill_cell(g, x, y, Color.new(0,0,255, [255 * (cell.food_pheremone / PHEREMONE_SCALE), 255].min.to_i))
      elsif cell.home_pheremone > 0
        fill_cell(g, x, y, Color.new(0, 255, 0, [255 * (cell.home_pheremone / PHEREMONE_SCALE), 255].min.to_i))
      end

      if cell.food > 0
        fill_cell(g, x, y, Color.new(255, 0, 0, [255 * (cell.food / FOOD_SCALE), 255].min.to_i))
      end

      if ant = cell.ant
        render_ant(ant, g, x, y)
      end
    end

    def render(g, sim)
      dim = Simulator::DIMENSIONS

      img = BufferedImage.new(SCALE * dim, 
                              SCALE * dim,
                              BufferedImage::TYPE_INT_ARGB)

      bg  = img.getGraphics

      bg.setColor(Color.white)
      bg.fillRect(0,0, img.getWidth, img.getHeight)

      sim.world.each do |cell, (x,y)|
        render_place(bg, cell, x, y)
      end

      bg.setColor(Color.blue)
      bg.drawRect(SCALE * Simulator::HOME_OFFSET, SCALE * Simulator::HOME_OFFSET,
                  SCALE * Simulator::NANTS_SQRT,  SCALE * Simulator::NANTS_SQRT)

      g.drawImage(img, 0, 0, nil)
      bg.dispose
    end
  end
end


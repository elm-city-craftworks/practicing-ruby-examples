require 'ray'

class Cell
  def initialize(pos)
    @shape = Ray::Polygon.rectangle([0,0,20,20], Ray::Color.white)
    @shape.outline  = Ray::Color.blue
    @shape.outlined = true
    @shape.pos = pos * 20
  end

  def pos
    @shape.pos
  end

  def paint(color)
    @shape.color = Ray::Color.send(color)
  end

  def draw(window)
    window.draw(@shape) 
  end
end


Ray.game "Hello world!", :size => [1000,1000] do
  register { add_hook :quit, method(:exit!) }

  cells = (1..48).to_a.product((1..48).to_a).map { |x,y| Cell.new(Ray::Vector2[x,y]) }

    scene :square do
      on(:mouse_press)   { @mousedown = true }
      on(:mouse_release) { @mousedown = false }
      on(:mouse_motion)  { |pos| @position  = pos }

      always do
        pos = @position
        if @mousedown
          clicked = cells.find { |cell| cell.pos; (cell.pos.x .. cell.pos.x + 20).include?(pos.x) && (cell.pos.y .. cell.pos.y + 20).include?(pos.y) }
          next unless clicked

          clicked.paint(:red)
        end
      end



      render do |win|
        cells.each { |cell| cell.draw(win) }
      end
  end

  scenes << :square
end

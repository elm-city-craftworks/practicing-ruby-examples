class Philosopher
  attr_reader :name, :thought, :left_chopsitck, :right_chopsitck

  def initialize(name)
    @name = name
  end

  def seat(table, position)
    @left_chopsitck  = table.left_chopsitck_at(position)
    @right_chopsitck = table.right_chopsitck_at(position)

    think
  end

  def think
    puts "#{name} is thinking"

    # Removed pause to see actual deadlock
    # sleep(rand)

    eat
  end

  def eat
    pick_chopsitcks

    puts "#{name} is eating."

    # Removed pause to see actual deadlock
    # sleep(rand)

    drop_chopsitcks

    think
  end

  def pick_chopsitcks
    left_chopsitck.pick
    right_chopsitck.pick
  end

  def drop_chopsitcks
    left_chopsitck.drop
    right_chopsitck.drop
  end
end

class CoordinatedPhilosopher < Philosopher

  def think
    puts "#{name} is thinking."

    # sleep(rand)

    @table.request_to_eat(self)
  end

  def eat
    puts "#{name} is eating."

    # sleep(rand)

    drop_chopsitcks

    think
  end
end
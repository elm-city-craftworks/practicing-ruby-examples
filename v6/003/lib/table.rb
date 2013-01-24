class Table
  attr_reader :chopsticks, :philosophers

  def initialize(philosophers)
    @philosophers = philosophers
    @chopsticks   = philosophers.size.times.map { Chopstick.new }
  end

  def max_chopsticks
    chopsticks.size - 1
  end

  def left_chopstick_at(position)
    index = (position - 1) % chopsticks.size
    chopsticks[index]
  end

  def right_chopstick_at(position)
    index = (position + 1) % chopsticks.size
    chopsticks[index]
  end

  def chopsticks_in_use
    @chopsticks.select { |f| f.in_use? }.size
  end
end

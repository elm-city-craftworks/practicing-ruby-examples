class Table
  attr_reader :chopsticks, :philosophers

  def initialize(philosophers)
    @philosophers = philosophers
    @chopsticks   = philosophers.size.times.collect { Chopstick.new }
  end

  def left_chopstick_at(position)
    index = position % chopsticks.size
    chopsticks[index]
  end

  def right_chopstick_at(position)
    index = (position + 1) % chopsticks.size
    chopsticks[index]
  end
end

class TableWithMutex < Table

  def request_to_eat(philosopher)
    @mutex.synchronize do
      sleep(rand) while chopsticks_in_use >= max_chopsticks
      philosopher.pick_chopsticks
    end

    philosopher.eat
  end

  def max_chopsticks
    chopsticks.size - 1
  end

  def chopsticks_in_use
    @chopsticks.select { |f| f.in_use? }.size
  end
end

class TableWithWaiter < Table
  attr_reader :waiter

  def initialize(philosophers, waiter)
    super(philosophers)
    @waiter = waiter
  end
end

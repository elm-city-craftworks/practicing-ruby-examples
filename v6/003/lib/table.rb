class Table
  attr_reader :chopsitcks, :philosophers

  def initialize(philosophers)
    @philosophers = philosophers
    @chopsitcks   = philosophers.size.times.collect { Chopstick.new }
  end

  def left_chopsitck_at(position)
    index = position % chopsitcks.size
    chopsitcks[index]
  end

  def right_chopsitck_at(position)
    index = (position + 1) % chopsitcks.size
    chopsitcks[index]
  end
end

class TableWithMutex < Table

  def request_to_eat(philosopher)
    @mutex.synchronize do
      sleep(rand) while chopsitcks_in_use >= max_chopsitcks
      philosopher.pick_chopsitcks
    end

    philosopher.eat
  end

  def max_chopsitcks
    chopsitcks.size - 1
  end

  def chopsitcks_in_use
    @chopsitcks.select { |f| f.in_use? }.size
  end
end

class TableWithWaiter < Table
  attr_reader :waiter

  def initialize(philosophers, waiter)
    super(philosophers)
    @waiter = waiter
  end
end
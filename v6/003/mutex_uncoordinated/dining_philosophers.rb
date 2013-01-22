class Chopstick
  def initialize
    @mutex = Mutex.new
  end

  def pick
    @mutex.lock
  end

  def drop
    @mutex.unlock
  end
end

class Table
  attr_reader :chopsticks, :philosophers

  def initialize(philosophers)
    @philosophers = philosophers
    @chopsticks   = philosophers.size.times.map { Chopstick.new }
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


class Philosopher
  attr_reader :name, :thought, :left_chopstick, :right_chopstick

  def initialize(name)
    @name = name
  end

  def seat(table, position)
    @left_chopstick  = table.left_chopstick_at(position)
    @right_chopstick = table.right_chopstick_at(position)
  end

  def think
    puts "#{name} is thinking"
  end

  def eat
    pick_chopsticks

    puts "#{name} is eating."

    drop_chopsticks
  end

  def pick_chopsticks
    left_chopstick.pick
    right_chopstick.pick
  end

  def drop_chopsticks
    left_chopstick.drop
    right_chopstick.drop
  end
end


names = %w{Heraclitus Aristotle Epictetus Schopenhauer Popper}

philosophers = names.map { |name| Philosopher.new(name) }

table = Table.new(philosophers)

threads = philosophers.map.with_index do |philosopher, i|
  Thread.new do 
    philosopher.seat(table, i) 
    
    loop do
      philosopher.think
      philosopher.eat
    end
  end
end

threads.each(&:join)

sleep(10000)

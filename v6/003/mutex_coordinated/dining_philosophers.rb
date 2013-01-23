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

  def in_use?
    @mutex.locked?
  end
end

class Philosopher
  attr_reader :name, :left_chopstick, :right_chopstick

  def initialize(name)
    @name = name
  end

  def dine(table, position)
    @table = table

    @left_chopstick  = table.left_chopstick_at(position)
    @right_chopstick = table.right_chopstick_at(position)

    Thread.new do
      loop do
        think
        @table.request_to_eat(self)
      end
    end
  end

  def think
    puts "#{name} is thinking."
  end

  def pick_chopsticks
    left_chopstick.pick
    right_chopstick.pick
  end

  def drop_chopsticks
    left_chopstick.drop
    right_chopstick.drop
  end

  def eat
    puts "#{name} is eating."

    drop_chopsticks
  end
end

class Table
  attr_reader :chopsticks, :philosophers

  def initialize(philosophers)
    @philosophers = philosophers

    @chopsticks = philosophers.size.times.map { Chopstick.new }

    @mutex = Mutex.new
  end

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


names = %w{Heraclitus Aristotle Epictetus Schopenhauer Popper}

philosophers = names.map { |name| Philosopher.new(name) }

table = Table.new(philosophers)

threads = philosophers.map.with_index do |philosopher, i|
  philosopher.dine(table, i) 
end

threads.each(&:join)
sleep

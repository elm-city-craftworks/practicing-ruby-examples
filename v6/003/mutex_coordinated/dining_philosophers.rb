require_relative "../lib/chopstick"
require_relative "../lib/table"

class Philosopher
  def initialize(name)
    @name   = name
  end

  def dine(table, position, waiter)
    @left_chopstick  = table.left_chopstick_at(position)
    @right_chopstick = table.right_chopstick_at(position)

    loop do
      think
      waiter.serve(table, self)
    end
  end

  def think
    puts "#{@name} is thinking."
  end

  def take_chopsticks
    @left_chopstick.take
    @right_chopstick.take
  end

  def drop_chopsticks
    @left_chopstick.drop
    @right_chopstick.drop
  end

  def eat
    puts "#{@name} is eating."

    drop_chopsticks
  end
end

class Waiter
  def initialize(capacity)
    @capacity = capacity
    @mutex    = Mutex.new
  end

  def serve(table, philosopher)
    @mutex.synchronize do
      sleep(rand) while table.chopsticks_in_use >= @capacity 
      philosopher.take_chopsticks
    end

    philosopher.eat
  end
end


names = %w{Heraclitus Aristotle Epictetus Schopenhauer Popper}

philosophers = names.map { |name| Philosopher.new(name) }

table  = Table.new(philosophers.size)
waiter = Waiter.new(philosophers.size - 1)

threads = philosophers.map.with_index do |philosopher, i|
  Thread.new { philosopher.dine(table, i, waiter) }
end

threads.each(&:join)
sleep

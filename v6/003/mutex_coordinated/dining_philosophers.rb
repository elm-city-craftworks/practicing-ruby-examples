require_relative "../lib/chopstick"
require_relative "../lib/table"

class Philosopher
  attr_reader :name, :left_chopstick, :right_chopstick

  def initialize(name)
    @name   = name
  end

  def dine(table, waiter, position)
    @left_chopstick  = table.left_chopstick_at(position)
    @right_chopstick = table.right_chopstick_at(position)

    loop do
      think
      waiter.serve(table, self)
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

class Waiter
  def initialize
    @mutex = Mutex.new
  end

  def serve(table, philosopher)
    @mutex.synchronize do
      sleep(rand) while table.chopsticks_in_use >= table.max_chopsticks
      philosopher.pick_chopsticks
    end

    philosopher.eat
  end
end


names = %w{Heraclitus Aristotle Epictetus Schopenhauer Popper}

philosophers = names.map { |name| Philosopher.new(name) }
waiter       = Waiter.new

table = Table.new(philosophers)

threads = philosophers.map.with_index do |philosopher, i|
  Thread.new { philosopher.dine(table, waiter, i) }
end

threads.each(&:join)
sleep

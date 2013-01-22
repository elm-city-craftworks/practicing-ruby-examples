require_relative 'lib/chopstick'
require_relative 'lib/table'

class Philosopher
  attr_reader :name, :thought, :left_chopstick, :right_chopstick

  def initialize(name)
    @name = name
  end

  def seat(table, position)
    @left_chopstick  = table.left_chopstick_at(position)
    @right_chopstick = table.right_chopstick_at(position)

    loop do
      think
      eat
    end
  end

  def think
    puts "#{name} is thinking"

    # Removed pause to see actual deadlock
    # sleep(rand)
  end

  def eat
    pick_chopsticks

    puts "#{name} is eating."

    # Removed pause to see actual deadlock
    # sleep(rand)

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

philosophers = names.collect { |name| Philosopher.new(name) }

table = Table.new(philosophers)

threads = philosophers.each_with_index.collect do |philosopher, i|
  Thread.new { philosopher.seat(table, i) }
end

threads.each(&:join)

sleep(10000)

require_relative 'lib/chopstick'
require_relative 'lib/table'

class Philosopher
  attr_reader :name, :thought, :left_chopsitck, :right_chopsitck

  def initialize(name)
    @name = name
  end

  def seat(table, position)
    @left_chopsitck  = table.left_chopsitck_at(position)
    @right_chopsitck = table.right_chopsitck_at(position)

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
    pick_chopsitcks

    puts "#{name} is eating."

    # Removed pause to see actual deadlock
    # sleep(rand)

    drop_chopsitcks
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


names = %w{Heraclitus Aristotle Epictetus Schopenhauer Popper}

philosophers = names.collect { |name| Philosopher.new(name) }

table = Table.new(philosophers)

threads = philosophers.each_with_index.collect do |philosopher, i|
  Thread.new { philosopher.seat(table, i) }
end

threads.each(&:join)

sleep(10000)

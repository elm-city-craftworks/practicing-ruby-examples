require_relative 'lib/chopstick'
require_relative 'lib/table'

class Philosopher
  attr_reader :name, :left_chopsitck, :right_chopsitck

  def initialize(name)
    @name = name
  end

  def seat(table, position)
    @table = table

    @left_chopsitck  = table.left_chopsitck_at(position)
    @right_chopsitck = table.right_chopsitck_at(position)

    think
  end

  def think
    puts "#{name} is thinking."

    # sleep(rand)

    @table.request_to_eat(self)
  end

  def pick_chopsitcks
    left_chopsitck.pick
    right_chopsitck.pick
  end

  def drop_chopsitcks
    left_chopsitck.drop
    right_chopsitck.drop
  end

  def eat
    puts "#{name} is eating."

    # sleep(rand)

    drop_chopsitcks

    think
  end
end

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

class Table
  attr_reader :chopsitcks, :philosophers

  def initialize(philosophers)
    @philosophers = philosophers

    @chopsitcks = philosophers.size.times.collect { Chopstick.new }

    @mutex = Mutex.new
  end

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

  def left_chopsitck_for(position)
    index = (position - 1) % chopsitcks.size
    chopsitcks[index]
  end

  def right_chopsitck_for(position)
    index = (position + 1) % chopsitcks.size
    chopsitcks[index]
  end

  def chopsitcks_in_use
    @chopsitcks.select { |f| f.in_use? }.size
  end
end

names = %w{Heraclitus Aristotle Epictetus Schopenhauer Popper}

philosophers = names.collect { |name| Philosopher.new(name) }

table = TableWithMutex.new(philosophers)

philosophers.each_with_index.collect do |philosopher, i|
  Thread.new { philosopher.seat(table, i) }
end

sleep(10000)

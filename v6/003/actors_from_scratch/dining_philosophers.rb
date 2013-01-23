require_relative '../lib/actors'

class Chopstick
  def initialize
    @mutex = Mutex.new
  end

  def pick
    @mutex.lock
  end

  def drop
    @mutex.unlock

  rescue ThreadError
    puts "Trying to drop a chopstick not acquired"
  end
end

class Table
  attr_reader :chopsticks, :philosophers, :waiter

  def initialize(philosophers, waiter)
    @philosophers = philosophers
    @chopsticks   = philosophers.size.times.map { Chopstick.new }
    @waiter       = waiter
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
  include Actor

  attr_reader :name, :thought, :left_chopstick, :right_chopstick

  def initialize(name)
    @name = name
  end

  def seat(table, position)
    @waiter = table.waiter

    @left_chopstick  = table.left_chopstick_at(position)
    @right_chopstick = table.right_chopstick_at(position)

    think
  end

  def think
    puts "#{name} is thinking."
    sleep(rand)
    @waiter.async.request_to_eat(Actor.current)
  end

  def eat
    pick_chopsticks
    puts "#{name} is eating."
    sleep(rand)
    drop_chopsticks
    @waiter.async.done_eating(Actor.current)

    think
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

class Waiter
  include Actor

  def initialize(philosophers)
    @eating = []
    @max_eating = philosophers.size - 1
  end

  def request_to_eat(philosopher)
    if @eating.size < @max_eating
      @eating << philosopher
      philosopher.async.eat
    else
      Actor.current.async.request_to_eat(philosopher)
      Thread.pass
    end
  end

  def done_eating(philosopher)
    @eating.delete(philosopher)
  end
end

names = %w{Heraclitus Aristotle Epictetus Schopenhauer Popper}

philosophers = names.map { |name| Philosopher.new(name) }

waiter = Waiter.new(philosophers)

table = Table.new(philosophers, waiter)

philosophers.each_with_index { |philosopher, i| philosopher.async.seat(table, i) }

sleep(10000)

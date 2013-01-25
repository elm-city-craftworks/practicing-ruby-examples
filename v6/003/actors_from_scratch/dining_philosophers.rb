require_relative '../lib/actors'
require_relative "../lib/chopstick"
require_relative "../lib/table"

class Philosopher
  include Actor

  def initialize(name)
    @name = name
  end

  def dine(table, position, waiter)
    @waiter = waiter

    @left_chopstick  = table.left_chopstick_at(position)
    @right_chopstick = table.right_chopstick_at(position)

    think
  end

  def think
    puts "#{@name} is thinking."
    sleep(rand)

    @waiter.async.request_to_eat(Actor.current)
  end

  def eat
    take_chopsticks

    puts "#{@name} is eating."
    sleep(rand)

    drop_chopsticks

    @waiter.async.done_eating(Actor.current)

    think
  end

  def take_chopsticks
    @left_chopstick.take
    @right_chopstick.take
  end

  def drop_chopsticks
    @left_chopstick.drop
    @right_chopstick.drop
  end
end

class Waiter
  include Actor

  def initialize(capacity)
    @eating = []
    @capacity = capacity
  end

  def request_to_eat(philosopher)
    if @eating.size < @capacity
      @eating << philosopher
      philosopher.async.eat
    else
      Actor.current.async.request_to_eat(philosopher)
    end
  end

  def done_eating(philosopher)
    @eating.delete(philosopher)
  end
end

names = %w{Heraclitus Aristotle Epictetus Schopenhauer Popper}

philosophers = names.map { |name| Philosopher.new(name) }

table  = Table.new(philosophers.size)
waiter = Waiter.new(philosophers.size - 1)

philosophers.each_with_index { |philosopher, i| philosopher.async.dine(table, i, waiter) }

sleep

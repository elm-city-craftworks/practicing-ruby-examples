require 'celluloid'
require_relative "../lib/chopstick"
require_relative "../lib/table"

class Philosopher
  include Celluloid

  attr_reader :name, :thought, :left_chopstick, :right_chopstick

  def initialize(name)
    @name = name
  end

  def dine(table, waiter, position)
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
    pick_chopsticks
    puts "#{@name} is eating."
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

  def finalize
    drop_chopsticks
  end
end

class Waiter
  include Celluloid

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
    end
  end

  def done_eating(philosopher)
    @eating.delete(philosopher)
  end
end

names = %w{Heraclitus Aristotle Epictetus Schopenhauer Popper}

philosophers = names.map { |name| Philosopher.new(name) }

waiter = Waiter.new(philosophers)
table = Table.new(philosophers)

philosophers.each_with_index do |philosopher, i| 
  philosopher.async.dine(table, waiter, i) 
end

sleep

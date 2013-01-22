require "bundler/setup"
require 'celluloid'

require_relative '../lib/chopstick'
require_relative '../lib/table'
require_relative '../lib/philosopher'

class ActorPhilosopher < Philosopher
  include Celluloid

  def seat(table, position)
    @waiter = table.waiter

    @left_chopsitck  = table.left_chopsitck_at(position)
    @right_chopsitck = table.right_chopsitck_at(position)

    think
  end

  def think
    puts "#{@name} is thinking."
    sleep(rand)
    @waiter.async.request_to_eat(Actor.current)
  end

  def eat
    pick_chopsitcks
    puts "#{@name} is eating."
    sleep(rand)
    drop_chopsitcks
    @waiter.async.done_eating(Actor.current)
    think
  end

  def finalize
    drop_chopsitcks
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
      Thread.pass
    end
  end

  def done_eating(philosopher)
    @eating.delete(philosopher)
  end
end

names = %w{Heraclitus Aristotle Epictetus Schopenhauer Popper}

philosophers = names.collect { |name| ActorPhilosopher.new(name) }

waiter = Waiter.new(philosophers)

table = TableWithWaiter.new(philosophers, waiter)

philosophers.each_with_index { |philosopher, i| philosopher.async.seat(table, i) }

sleep

at_exit { exit! }

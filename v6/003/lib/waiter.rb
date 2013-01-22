class Waiter
  def initialize(philosophers)
    @eating = []
    @max_eating = philosophers.size - 1
  end

  def request_to_eat(philosopher)
    if @eating.size < @max_eating
      @eating << philosopher
      philosopher.eat!
    else
      Actor.current.request_to_eat!(philosopher)
      Thread.pass
    end
  end

  def done_eating(philosopher)
    @eating.delete(philosopher)
  end
end

class ActorWaiter < Waiter
  extend Actor
end
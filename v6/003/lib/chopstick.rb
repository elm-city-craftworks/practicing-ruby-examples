class Chopstick
  def initialize
    @mutex    = Mutex.new
  end

  def pick
    @mutex.lock
  end

  def drop
    @mutex.unlock
  end
end
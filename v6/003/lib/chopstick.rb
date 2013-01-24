class Chopstick
  def initialize
    @mutex = Mutex.new
  end

  def take
    @mutex.lock
  end

  def drop
    @mutex.unlock

  rescue ThreadError
    puts "Trying to drop a chopstick not acquired"
  end

  def in_use?
    @mutex.locked?
  end
end


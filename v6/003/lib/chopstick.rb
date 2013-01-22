class Chopstick
  def initialize
    @mutex    = Mutex.new
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
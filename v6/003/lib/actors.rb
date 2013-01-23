require 'thread'

module Actor

  module ClassMethods
    def new(*args, &block)
      Proxy.new(super)
    end
  end

  class << self
    def included(klass)
      klass.extend(ClassMethods)
    end

    def current
      Thread.current[:actor]
    end
  end

  class Proxy
    def initialize(target)
      @target  = target
      @mailbox = Queue.new
      @mutex   = Mutex.new
      @running = true

      @async_proxy = AsyncProxy.new(self)

      @thread = Thread.new do
        Thread.current[:actor] = self
        process_messages 
      end
    end

    def async(meth = nil, *args)
      if meth
        @mailbox << [meth, args]
      else
        @async_proxy
      end
    end

    def terminate
      @running = false
    end

    def method_missing(meth, *args)
      process_message(meth, *args)
    end

    private

    def process_messages
      while @running
        meth, args = @mailbox.pop
        process_message(meth, *args)
      end

      rescue Exception => ex
        puts "Error while running actor: #{ex}"
    end

    def process_message(meth, *args)
      @mutex.synchronize do
        @target.public_send(meth, *args)
      end
    end
  end

  class AsyncProxy
    def initialize(actor)
      @actor = actor
    end

    def method_missing(meth, *args)
      @actor.async(meth, *args)
    end
  end
end

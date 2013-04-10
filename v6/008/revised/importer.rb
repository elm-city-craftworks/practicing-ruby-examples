# This is *more complex* than the script, don't let anyone tell you otherwise
#
# But...
# Line count is not the best metric for understandability / maintainability
#
# This extra code reduces the amount of concepts we need to think about
# each time we make a change (possibly)
#
# It also makes it possible for changes to be made in relative isolation
#
# The cost is that you need to name concepts, pick the right level of
# abstraction for them, and connect them together in a web.
#
# Benefit is only as good as what you *don't* need to think about
# after learning each object's interface.

require "bigdecimal"

class PriceInformation
  ZIPCODE_MATCHER = /\A\d{5}\z/
  PRICE_MATCHER   = /\A\$\d+\.\d{2}\z/

  def initialize(zipcode: raise, shipping_rate: raise)
    raise "Zipcode validation failed"       unless zipcode[ZIPCODE_MATCHER]
    raise "Shipping rate validation failed" unless shipping_rate[PRICE_MATCHER]
    
    @zipcode       = zipcode 
    @shipping_rate = BigDecimal.new(shipping_rate[1..-1])
  end

  attr_reader :zipcode, :shipping_rate
end

# ..........................................................................

require "pstore"

class Importer
  def self.update(filename)
    store = PStore.new(filename)

    store.transaction do
      yield new(store)
    end
  end

  def initialize(store)
    self.store    = store
    self.imported = []
  end

  def []=(key, new_value)
    raise_if_duplicate(key)

    old_value = store[key]

    return if old_value == new_value # nothing to do!

    if old_value.nil?
      ChangeLog.new_record(key, new_value)
    else
      ChangeLog.updated_record(key, old_value, new_value)
    end

    store[key] = new_value
  end

  private

  attr_accessor :store, :imported

  def raise_if_duplicate(key)
    raise "Duplicate key in import data: #{key}" if imported.include?(key)
    imported << key
  end
end

# ..........................................................................

class << (ChangeLog = Object.new)
  def new_record(key, value)
    STDERR.puts "Adding #{key}: #{f(value)}"
  end

  def updated_record(key, old_value, new_value)
    STDERR.puts "Updating #{key}: Was #{f(old_value)}, Now #{f(new_value)}" 
  end

  private

  def f(value)
    '%.2f' % value
  end
end

# ..........................................................................

require "csv"

Importer.update("shipping_rates.store") do |store|
  CSV.foreach(ARGV[0] || "rates.csv") do |r|
    info = PriceInformation.new(zipcode: r[0], shipping_rate: r[1])
    
    store[info.zipcode] = info.shipping_rate
  end
end

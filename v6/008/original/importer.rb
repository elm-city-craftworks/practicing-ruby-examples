require "csv"
require "pstore"
require "bigdecimal"

store = PStore.new("shipping_rates.store")

store.transaction do
  CSV.foreach(ARGV[0] || "rates.csv") do |r|
    zip    = r[0]
    amount = BigDecimal.new(r[1][1..-1])
    
    store[zip] = amount
  end
end

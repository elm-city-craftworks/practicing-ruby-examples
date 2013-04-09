require "csv"
require "pstore"
require "bigdecimal"

store = PStore.new("shipping_rates.store")

store.transaction do
  processed_zipcodes  = []
  
  CSV.foreach(ARGV[0] || "rates.csv") do |r|
    raise unless r[0][/\A\d{5}\z/]
    raise unless r[1][/\A\$\d+\.\d{2}\z/]
    
    zip    = r[0]
    amount = BigDecimal.new(r[1][1..-1])

    raise "duplicate entry: #{zip}" if processed_zipcodes.include?(zip)
    processed_zipcodes << zip
    
    next if store[zip] == amount

    if store[zip].nil?
      STDERR.puts("Adding new entry for #{zip}: #{'%.2f' % amount}")
    elsif store[zip] != amount
      STDERR.puts("Updating entry for #{zip}: was #{'%.2f' % store[zip]}, now #{'%.2f' % amount}")
    end
    
    store[r[0]] = BigDecimal.new(r[1][1..-1])
  end
end

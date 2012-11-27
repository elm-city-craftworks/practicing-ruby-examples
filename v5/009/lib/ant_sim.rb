basedir = File.join(File.dirname(__FILE__), "ant_sim")

%w[ant cell world actor simulator optimizer visualization].each do |lib|
  require "#{basedir}/#{lib}"
end

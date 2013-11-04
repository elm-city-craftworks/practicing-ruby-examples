# Install ruby-build
include_recipe "ruby_build"

# Build and install Ruby version using ruby-build. By installing it to
# /usr/local, we ensure it is the new global Ruby version from now on.
ruby_build_ruby "2.0.0-p247" do
  prefix_path "/usr/local"
end

# Update to the latest RubyGems version
execute "update-rubygems" do
  command "gem update --system"
  not_if  "gem list | grep -q rubygems-update"
end

# Install Bundler
gem_package "bundler"

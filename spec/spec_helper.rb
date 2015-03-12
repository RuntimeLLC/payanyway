require 'pry'
require 'rspec'
require 'payanyway'

Dir['spec/support/**/*.rb'].each do |file|
  require File.join(File.dirname(__FILE__), '..', file)
end
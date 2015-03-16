require 'rubygems'
require 'bundler/setup'

require 'combustion'
Bundler.require :default, :development

Combustion.initialize! :action_controller, :action_view

require 'payanyway'
require 'rspec/rails'
require 'pry'

RSpec.configure do |config|
  config.before(:each) do
    current_root = Payanyway::Engine.root
    Payanyway::Engine.stub(:root).and_return(File.join(current_root, Combustion.path))
  end
end
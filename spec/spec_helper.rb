require 'rubygems'
require 'bundler/setup'

require 'combustion'

Combustion.initialize! :action_controller, :action_view

require 'rspec/rails'
require 'payanyway'
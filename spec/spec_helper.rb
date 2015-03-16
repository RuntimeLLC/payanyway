require 'rubygems'
require 'bundler/setup'

require 'combustion'
Bundler.require :default, :development

Combustion.initialize! :action_controller, :action_view

require 'payanyway'
require 'rspec/rails'
require 'pry'
ENV['RAILS_ENV'] ||= 'test'

require 'rubygems'
require 'bundler/setup'

require 'combustion'
Bundler.require :default, :development

Combustion.initialize! :action_controller, :action_view

require 'payanyway'
require 'rspec/rails'
require 'pry'
require 'codeclimate-test-reporter'

CodeClimate::TestReporter.start if ENV['CODECLIMATE_REPO_TOKEN']


RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
end
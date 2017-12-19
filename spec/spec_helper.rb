require 'rspec'
require 'pry'
require_relative '../lib/oriented'
require 'orientdb'
require 'active_support'

Dir['./spec/support/**/*.rb'].sort.each {|f| require f}

RSpec.configure do |config|
  config.filter_run_excluding broken: true
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.before(:each) do
    Oriented.connection
  end

  config.include LoggerCapture
end

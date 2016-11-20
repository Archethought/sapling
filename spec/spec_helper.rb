$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "sapling"

Dir["#{Dir.pwd}/spec/lib/*.rb"].each(&method(:require))

RSpec.configure do |c|
  c.after(:each) do
    Sapling.reset_configuration
  end
end

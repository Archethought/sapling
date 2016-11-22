module Sapling
  class Configuration
    attr_reader :seeds, :contexts, :sequences

    def initialize
      @seeds = Registry.new('Seed')
      @contexts = Registry.new('ExecutionContext')
      @sequences = Registry.new('Sequences')
    end
  end
end

module Sapling
  class Configuration
    attr_reader :seeds, :contexts

    def initialize
      @seeds = Registry.new('Seed')
      @contexts = Registry.new('ExecutionContext')
    end
  end
end

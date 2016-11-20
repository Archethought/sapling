require 'sapling/version'
require 'sapling/railtie'
require 'sapling/seed'
require 'sapling/registry'
require 'sapling/configuration'
require 'sapling/execution_context'

module Sapling
  class << self
    delegate :seeds, :contexts, to: :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset_configuration
    @configuration = nil
  end

  # Registers new seeds into the global namespace
  def self.register_seed(seed)
    seeds.register(seed.name, seed)
  end

  def self.register_context(context)
    contexts.register(context.name, context)
  end

  # Top level DSL for creating seed definitions. 
  def self.define(&block)
    DefineDSL.run(block)
  end

  # Top level DSL for defining how seed definitions are to be used.
  def self.seed(&block)
    context = ExecutionContext.new
    context.instance_eval(&block)
    contexts.register(:default, context)
  end

  # Run the seed generator
  def self.create_seeds(name=:default)
    context = contexts.find(name)
    context.run(:create)
  end

  class DefineDSL
    def seed(name, &block)
      seed = Seed.new(name)
      seed.instance_eval(&block) if block_given?
      Sapling.register_seed(seed)
    end

    def self.run(block)
      new.instance_eval(&block)
    end
  end
end

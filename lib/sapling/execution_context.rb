require 'active_support/core_ext/array/extract_options'

module Sapling
  class ExecutionContext
    attr_reader :name, :instructions

    def initialize(name=:default)
      @name = name
      @instructions = []
    end

    def run(op)
      case op
      when :create then run_create
      else raise ArgumentError.new("Unknown execution operation: #{op}")
      end
    end

    def method_missing(name, *args)
      attrs = args.extract_options!

      if Sapling.seeds.registered?(name)
        seed = Sapling.seeds[name]
        @instructions << {seed: seed, attrs: attrs}
      else
        super
      end
    end

    private

    def run_create
      @instructions.each do |instruction|
        seed = instruction[:seed]
        seed.model_class.create(seed.attributes.merge(instruction[:attrs]))
      end
    end
  end
end

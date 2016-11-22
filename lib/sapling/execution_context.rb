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

    def method_missing(name, *args, &block)
      attrs = args.extract_options!
      seed_count = 1

      if Sapling.seeds.registered?(name)
        seed_count, *args = args if args.count > 0

        if name.is_a? Sapling::Seed
          seed = name
        else
          seed = Sapling.seeds[name]
        end

        instruction = {seed: seed, attrs: attrs, count: seed_count}

        if block_given?
          context = ExecutionContext.new(seed)
          context.instance_eval(&block)
          instruction[:sub_context] = context
        end

        @instructions << instruction
      else
        super
      end
    end

    protected

    def run_create(parent=nil)
      @instructions.each do |instruction|
        seed = instruction[:seed]
        attrs = seed.attributes

        instruction[:attrs].each do |name, value|
          value = value.call(seed.send(name)) if value.respond_to? :call
          attrs[name] = value
        end

        if parent
          assoc_name = seed.associations[parent.class]
          attrs[assoc_name] = parent
        end

        instruction[:count].times do
          record = seed.model_class.create(attrs)

          if instruction[:sub_context]
            context = instruction[:sub_context]
            context.run_create(record)
          end
        end
      end
    end
  end
end

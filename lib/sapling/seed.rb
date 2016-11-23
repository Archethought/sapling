module Sapling
  class Seed
    attr_reader :name, :associations

    def initialize(name)
      @name = name
      @attributes = []
      @definition = Module.new
      @associations = {}
    end

    def model_class
      name.to_s.classify.constantize
    end

    def attributes
      Hash[ @attributes.map {|attr| [attr, @definition.send(attr)]} ]
    end

    def sequence(name, &block)
      sequence = Sequence.new("#{self.name}_#{name}", block)
      Sapling.register_sequence(sequence)

      seq_name = "#{@name}_#{name}"

      define_attribute(name) do
        Sapling.sequences.find(seq_name).next
      end
    end

    def association(name, opts={})
      opts[:class_name] ||= name.to_s.classify
      @associations[opts[:class_name].constantize] = name
    end

    def method_missing(name, value=nil, opts={}, &block)
      if value || block_given?
        m = value ? proc { value } : block
        define_attribute(name, &m)
      else
        super
      end
    end

    def define_attribute(name, &block)
      @definition.define_singleton_method(name, &block)
      @attributes << name
    end
  end
end

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
      m = proc do
        Sapling.sequences.find(seq_name).next
      end

      @definition.define_singleton_method(name, &m)
      @attributes << name
    end

    def method_missing(name, value=nil, opts={}, &block)
      super if name.to_s == 'define_method'

      if name.to_s == 'association'
        opts[:class_name] ||= value.to_s.classify
        @associations[opts[:class_name].constantize] = value
      else
        m = value ? proc { value } : block
        @definition.define_singleton_method(name, &m)
        @attributes << name
      end
    end
  end
end

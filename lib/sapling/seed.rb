module Sapling
  class Seed
    attr_reader :name, :associations

    def initialize(name)
      @name = name
      @attributes = []
      @associations = {}
    end

    def model_class
      name.to_s.classify.constantize
    end

    def attributes
      Hash[ @attributes.map {|attr| [attr, send(attr)]} ]
    end

    def sequence(name, &block)
      sequence = Sequence.new("#{self.name}_#{name}", block)
      Sapling.register_sequence(sequence)

      m = proc do
        result = Sapling.sequences.find("#{self.name}_#{name}").next
        result
      end

      singleton = class << self; self; end
      singleton.send(:define_method, name, m)
      @attributes << name
    end

    def method_missing(name, value=nil, opts={}, &block)
      super if name.to_s == 'define_method'

      if name.to_s == 'association'
        opts[:class_name] ||= value.to_s.classify
        @associations[opts[:class_name].constantize] = value
      else
        m = value ? proc { value } : block
        singleton = class << self; self; end
        singleton.send(:define_method, name, &m)

        @attributes << name
      end
    end
  end
end

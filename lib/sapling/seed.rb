module Sapling
  class Seed
    attr_reader :name

    def initialize(name)
      @name = name
      @attributes = []
    end

    def model_class
      name.to_s.classify.constantize
    end

    def attributes
      Hash[ @attributes.map {|attr| [attr, send(attr)]} ]
    end

    def method_missing(name, value=nil, &block)
      super if name.to_s == 'define_method'

      m = value ? proc { value } : block
      singleton = class << self; self; end
      singleton.send(:define_method, name, &m)

      @attributes << name
    end
  end
end

module Sapling
  class Seed
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def model_class
      name.to_s.classify.constantize
    end
  end
end

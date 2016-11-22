module Sapling
  class Sequence
    attr_reader :name

    def initialize(name, block)
      @name = name
      @block = block
      @iter = 1
    end

    def next
      result = @block.call(@iter)
      @iter += 1
      result
    end
  end
end

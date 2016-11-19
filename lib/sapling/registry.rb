module Sapling
  class Registry
    include Enumerable

    attr_reader :name

    def initialize(name)
      @name = name
      @items = {}
    end

    def register(name, item)
      @items[name] = item
    end

    def registered?(name)
      @items.has_key? name
    end

    def each(&block)
      @items.values.uniq.each(&block)
    end

    def find(name)
      if registered?(name)
        @items[name]
      else
        raise ArgumentError.new("#{@name} registry does not have: #{name}")
      end
    end

    alias :[] :find
  end
end

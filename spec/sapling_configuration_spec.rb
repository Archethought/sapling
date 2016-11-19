require 'spec_helper'

RSpec.describe Sapling::Configuration do
  describe '#seeds' do
    it 'creates a seed registry during inialization' do
      expect(subject.seeds).to be_a Sapling::Registry
    end
  end

  describe '#contexts' do
    it 'creates a context registry during initialization' do
      expect(subject.contexts).to be_a Sapling::Registry
    end
  end
end

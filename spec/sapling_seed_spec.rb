require 'spec_helper'

RSpec.describe Sapling::Seed do
  describe '#name' do
    it 'is initialized with a name' do
      seed = Sapling::Seed.new :user
      expect(seed.name).to eq :user
    end
  end

  describe '#model_class' do
    it 'returns a class based on the name' do
      seed = Sapling::Seed.new :user
      expect(seed.model_class).to eq User
    end
  end
end

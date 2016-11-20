require 'spec_helper'

RSpec.describe Sapling::ExecutionContext do
  describe '#name' do
    it 'is default when no name is given' do
      expect(subject.name).to eq :default
    end
  end

  describe '#method_missing' do
    context 'with a registered seed' do
      let(:seed) { Sapling::Seed.new(:user) }

      before do
        Sapling.register_seed(seed)
      end

      it 'creates an instruction for the seed' do
        subject.user
        expect(subject.instructions).to eq [{seed: seed}]
      end
    end
  end
end

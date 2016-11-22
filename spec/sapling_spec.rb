require "spec_helper"

describe Sapling do
  describe '#configuration' do
    it 'creates a new configuration when none has been set' do
      Sapling.instance_variable_set(:@configuration, nil)
      expect(Sapling.configuration).to be_a Sapling::Configuration
    end

    it 'does not create a new configuration if one exists' do
      config = Sapling.configuration
      expect(Sapling.configuration).to eq config
    end
  end

  describe '#reset_configuration' do
    it 'creates a new configuration object' do
      config = Sapling.configuration
      Sapling.reset_configuration
      expect(Sapling.configuration).not_to eq config
    end
  end

  describe '#register_seed' do
    it 'adds a seed to the seed registry' do
      seed = Sapling::Seed.new('foo')
      Sapling.register_seed(seed)
      expect(Sapling.seeds.find('foo')).to eq seed
    end
  end

  describe '#register_context' do
    it 'adds a context to the context registry' do
      context = Sapling::ExecutionContext.new('foo')
      Sapling.register_context(context)
      expect(Sapling.contexts.find('foo')).to eq context
    end
  end

  describe 'creating seeds' do
    before do
      allow(User).to receive(:create)
    end

    context 'when a seed is defined with only a model name' do
      before do
        Sapling.define do
          seed :user
        end

        Sapling.seed do
          user
        end
      end

      it 'registers a seed' do
        expect(Sapling.seeds.registered?(:user)).to be true
      end

      it 'creates a new user record' do
        Sapling.create_seeds
        expect(User).to have_received(:create)
      end
    end

    context 'when a seed is defined with attributes' do
      before do
        Sapling.define do
          seed :user do
            first_name 'John'
            last_name 'Doe'
          end
        end

        Sapling.seed do
          user
        end
      end

      it 'registers a seed with attributes' do
        seed = Sapling.seeds.find(:user)
        expect(seed.first_name).to eq 'John'
        expect(seed.last_name).to eq 'Doe'
      end

      it 'creates a new record with attributes' do
        Sapling.create_seeds
        expect(User).to have_received(:create).with(first_name: 'John', last_name: 'Doe')
      end
    end

    context 'when a seed is defined with dynamic attributes' do
      before do
        Sapling.define do
          seed :user do
            answer { 40 + 2 }
          end
        end
      end

      it 'registers a seed with dynamic attributes' do
        seed = Sapling.seeds.find(:user)
        expect(seed.answer).to eq 42
      end
    end
  end
end

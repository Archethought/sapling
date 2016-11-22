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
    let(:user) { User.new }
    let(:post) { Post.new }

    before do
      allow(User).to receive(:create).and_return(user)
      allow(Post).to receive(:create).and_return(post)
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

        Sapling.seed do
          user
        end
      end

      it 'creates a seed with the computed value' do
        Sapling.create_seeds
        expect(User).to have_received(:create).with(answer: 42)
      end
    end

    context 'when a seed has an attribute overriden' do
      before do
        Sapling.define do
          seed :user do
            first_name 'John'
          end
        end

        Sapling.seed do
          user first_name: 'Jane'
        end
      end

      it 'creates a new record with the overriden value' do
        Sapling.create_seeds
        expect(User).to have_received(:create).with(first_name: 'Jane')
      end
    end

    context 'when a seed has a dynamic attribute overriden' do
      before do
        Sapling.define do
          seed :user do
            answer { 40 + 1 }
          end
        end

        Sapling.seed do
          user answer: proc {|a| a + 1 }
        end
      end

      it 'creates a new record with the overriden dynamic value' do
        Sapling.create_seeds
        expect(User).to have_received(:create).with(answer: 42)
      end
    end

    context 'when seeding multiple times' do
      before do
        Sapling.define do
          seed :user do
            first_name 'John'
          end
        end

        Sapling.seed do
          user 3
        end
      end

      it 'creates 3 new user records' do
        Sapling.create_seeds
        expect(User).to have_received(:create).exactly(3).times.with(first_name: 'John')
      end
    end

    context 'when a seed configuration has a nested seed' do
      before do
        Sapling.define do
          seed :user do
            first_name 'John'
          end

          seed :post do
            subject 'A test message'
            association :user
          end
        end

        Sapling.seed do
          user { post }
        end
      end

      it 'creates a new record for the nested model with the parent matching the association' do
        Sapling.create_seeds
        expect(User).to have_received(:create).with(first_name: 'John')
        expect(Post).to have_received(:create).with(subject: 'A test message', user: user)
      end
    end

    context 'when a seed is defined with an association and class name' do
      before do
        Sapling.define do
          seed :user
          seed :post do
            association :owner, class_name: 'User'
          end
        end

        Sapling.seed do
          user { post }
        end
      end

      it 'creates a record from the class name with the given association name' do
        Sapling.create_seeds
        expect(Post).to have_received(:create).with(owner: user)
      end
    end

    context 'when a seed is configured with nested seeds with count' do
      before do
        Sapling.define do
          seed :user do
            first_name 'John'
          end

          seed :post do
            subject 'A test message'
            association :user
          end
        end

        Sapling.seed do
          user(3) { post 3 }
        end
      end

      it 'creates the nested model n*m times' do
        Sapling.create_seeds
        expect(User).to have_received(:create).exactly(3).times
        expect(Post).to have_received(:create).exactly(9).times
      end
    end
  end
end

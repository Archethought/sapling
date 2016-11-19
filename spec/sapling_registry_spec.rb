require 'spec_helper'

RSpec.describe Sapling::Registry do
  subject { Sapling::Registry.new('test') }

  describe '#name' do
    it 'makes the initialized name readable' do
      expect(subject.name).to eq 'test'
    end
  end

  describe '#registered?' do
    it 'is true if the seed has been registered' do
      expect(subject.registered?('foo')).to be false
      subject.register('foo', 'foo')
      expect(subject.registered?('foo')).to be true
    end
  end

  describe '#each' do
    context 'with no items registered' do
      it 'does not iterate the block' do
        count = subject.inject(0) {|count| count + 1 }
        expect(count).to be_zero
      end
    end

    context 'with registered items' do
      before do
        subject.register("foo", "foo")
        subject.register("bar", "bar")
      end

      it 'iterates for each item' do
        count = subject.inject(0) {|count| count + 1}
        expect(count).to eq 2
      end
    end

    context 'with aliased registered items' do
      before do
        subject.register 'foo', 'foo'
        subject.register 'bar', 'foo'
      end

      it 'iterates only the unique items' do
        count = subject.inject(0) {|count| count + 1 }
        expect(count).to eq 1
      end
    end
  end

  %w(find []).each do |m|
    describe "##{m}" do
      context 'with no registered items' do
        it 'raises an argument error' do
          expect { subject.send(m, 'foo') }.to raise_error(ArgumentError)
        end
      end

      context 'with a registered item' do
        before do
          subject.register('key', 'value')
        end

        it 'returns the registered item' do
          expect(subject.send(m, 'key')).to eq 'value'
        end
      end
    end
  end
end

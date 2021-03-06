require_relative '../../spec_helper'

require 'trick_bag/functional/functional'



module TrickBag

  describe 'Composite predicates' do

    false_func = ->(x) { false }
    true_func  = ->(x) { true }
    all_true_funcs = [true_func] * 2
    all_false_funcs = [false_func] * 2
    mixed_true_false_funcs = [true_func, false_func]

    context "none?" do

      specify "returns true when all are false" do
        expect(TrickBag.none_with_object?(all_false_funcs, 1)).to eq(true)
      end

      specify "returns false when all are true" do
        expect(TrickBag.none_with_object?(all_true_funcs, 1)).to eq(false)
      end

      specify "returns false when some are false and some are true" do
        expect(TrickBag.none_with_object?(mixed_true_false_funcs, 1)).to eq(false)
      end
    end


    context "any?" do

      specify "returns false when all are false" do
        expect(TrickBag.any_with_object?(all_false_funcs, 1)).to eq(false)
      end

      specify "returns true when all are true" do
        expect(TrickBag.any_with_object?(all_true_funcs, 1)).to eq(true)
      end

      specify "returns true when some are false and some are true" do
        expect(TrickBag.any_with_object?(mixed_true_false_funcs, 1)).to eq(true)
      end
    end


    context "all?" do

      specify "returns false when all are false" do
        expect(TrickBag.all_with_object?(all_false_funcs, 1)).to eq(false)
      end

      specify "returns true when all are true" do
        expect(TrickBag.all_with_object?(all_true_funcs, 1)).to eq(true)
      end

      specify "returns false when some are false and some are true" do
        expect(TrickBag.all_with_object?(mixed_true_false_funcs, 1)).to eq(false)
      end
    end
  end
end

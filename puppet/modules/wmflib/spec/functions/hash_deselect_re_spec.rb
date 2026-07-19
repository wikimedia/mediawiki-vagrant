require 'spec_helper'

describe 'hash_deselect_re' do
  it 'should raise an error if there are less than 2 arguments' do
    is_expected.to run.with_params('a').and_raise_error(ArgumentError)
  end

  it 'should raise an error if there are more than 2 arguments' do
    is_expected.to run.with_params('a', 'b', 'c').and_raise_error(ArgumentError)
  end

  it 'should select the right keys (simple)' do
    is_expected.to run.with_params('^a', {'abc' => 1, 'def' => 2, 'asdf' => 3}).and_return({'def' => 2})
  end

  it 'should select the right keys (neg lookahead)' do
    is_expected.to run.with_params('^(?!a)', {'abc' => 1, 'def' => 2, 'asdf' => 3}).and_return({'abc' => 1, 'asdf' => 3})
  end
end

require 'spec_helper'

describe 'ensure_mounted' do
  it 'should raise an error if there are less than 1 arguments' do
    is_expected.to run.with_params.and_raise_error(ArgumentError)
  end

  it 'should raise an error if there are more than 1 arguments' do
    is_expected.to run.with_params('a', 'b').and_raise_error(ArgumentError)
  end

  it "should return 'mounted' for param 'present'" do
    is_expected.to run.with_params('present').and_return('mounted')
  end

  it "should return 'mounted' for param true" do
    is_expected.to run.with_params(true).and_return('mounted')
  end

  it "should return 'absent' for param 'absent'" do
    is_expected.to run.with_params('absent').and_return('absent')
  end

  it "should return false for param false" do
    is_expected.to run.with_params(false).and_return(false)
  end
end

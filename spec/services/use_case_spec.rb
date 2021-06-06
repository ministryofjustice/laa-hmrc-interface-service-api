require 'rails_helper'

RSpec.describe UseCase do
  subject(:use_case) { described_class.new }

  it { is_expected.to be_a UseCase }
end

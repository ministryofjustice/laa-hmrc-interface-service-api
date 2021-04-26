require 'rails_helper'

describe ApplicationUser, :model do
  subject { described_class.new }

  describe 'use case validation' do
    context 'can have multiple values 1-4' do
      subject(:multiple_use_cases) { build :application_user, use_cases: [1, 2, 3, 4] }

      it { is_expected.to be_valid }
    end

    describe 'fails if mix of valid and invalid values' do
      subject(:use_cases) { build :application_user, use_cases: %i[1 two] }

      it { expect(subject.valid?).to be false }
    end

    describe 'fails if non-numeric values' do
      subject(:use_cases) { build :application_user, use_cases: %i[one two] }

      it { expect(subject.valid?).to be false }
    end

    describe 'fails if text values' do
      subject(:use_cases) { build :application_user, use_cases: %w[hello] }

      it { is_expected.to be_invalid }
    end
  end
end

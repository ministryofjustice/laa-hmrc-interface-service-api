# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Submission, type: :model do
  subject(:submission) { described_class.new(params) }

  let(:params) do
    {
      use_case: 'one',
      first_name: 'Bob',
      last_name: 'Smith',
      nino: 'XX123456Y',
      dob: '1990-01-01',
      start_date: '2021-01-01',
      end_date: '2021-03-31'
    }
  end

  it {
    is_expected.to validate_inclusion_of(:use_case).in_array(%w[one two three four]).with_message(/Invalid use case/)
  }

  describe '.as_json' do
    subject(:as_json) { submission.as_json }

    it 'returns the expected values' do
      expect(as_json.keys).to match_array %w[use_case first_name last_name nino dob start_date end_date]
    end

    it 'does not include standard model values' do
      expect(as_json.keys).to_not include %w[id status created_at updated_at]
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Submission, type: :model do
  subject { described_class.new }

  it {
    is_expected.to validate_inclusion_of(:use_case).in_array(%w[one two three four]).with_message(/Invalid use case/)
  }
end

require 'rails_helper'

RSpec.describe CallEndpointWorker do
  subject(:worker) { described_class.new }
  let(:task) { create :task }
  it { is_expected.to be_a CallEndpointWorker }
end

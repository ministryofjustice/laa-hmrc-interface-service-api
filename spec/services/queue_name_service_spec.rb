require 'rails_helper'

RSpec.describe QueueNameService do
  describe '.call' do
    subject(:call) { described_class.call }

    context 'when the service is called in UAT' do
      before do
        Settings.sentry.environment = 'uat'
        Settings.status.app_branch = 'this-is/a.test-branch'
      end
      it 'should prefix the submission queue name with the branch name' do
        expect(call).to eq 'this-is-a-test-branch-submissions'
      end
    end

    context 'when the service is called anywhere other than UAT' do
      before do
        Settings.sentry.environment = 'test'
      end
      it 'sets the submission queue name to /submissions/' do
        expect(call).to eq 'submissions'
      end
    end
  end
end

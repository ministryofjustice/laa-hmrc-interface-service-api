require 'rails_helper'

RSpec.describe Task, :model do
  subject(:task) { described_class.new(application_user: application_user, data: jwt, use_case: :one) }
  let(:application_user) { create :application_user }
  let(:jwt) { create_jwt_with(request_hash.to_json, application_user.secret_key) }
  let(:request_hash) do
    {
      first_name: 'fname',
      last_name: 'lname',
      dob: '1990-01-01',
      nino: 'QQ123456C',
      from: '2020-01-01',
      to: '2020-04-01'
    }
  end
  let(:expected_data) do
    {
      'first_name' => 'fname',
      'last_name' => 'lname',
      'dob' => '1990-01-01',
      'nino' => 'QQ123456C',
      'from' => '2020-01-01',
      'to' => '2020-04-01'
    }
  end

  before { REDIS.set('use_case_one_bearer_token', 'fake_token_value') }

  describe 'initializing sets status and result' do
    it { expect(task.created?).to eq true }
    it { expect(task.pending?).to eq true }
  end

  describe 'parse_payload' do
    subject(:parse_payload) { task.parse_payload }

    context 'when all values are good' do
      it { expect { parse_payload }.to change { task.data }.to(expected_data) }
      it { is_expected.to be true }
    end

    context 'when nil data is sent' do
      let(:jwt) { nil }

      it { expect { parse_payload }.to change { task.completed? }.to(true) }
      it { expect { parse_payload }.to change { task.errored? }.to(true) }
      it { expect { parse_payload }.to change { task.outcome }.to({ 'error' => 'data_missing' }) }
      it { is_expected.to be false }
    end

    context 'when no data is sent' do
      let(:jwt) { '' }

      it { expect { parse_payload }.to change { task.completed? }.to(true) }
      it { expect { parse_payload }.to change { task.errored? }.to(true) }
      it { expect { parse_payload }.to change { task.outcome }.to({ 'error' => 'data_missing' }) }
      it { is_expected.to be false }
    end

    context 'when data encoded with the wrong key is sent' do
      let(:jwt) { create_jwt_with(request_hash, 'incorrect_secret_key') }

      it { expect { parse_payload }.to change { task.completed? }.to(true) }
      it { expect { parse_payload }.to change { task.errored? }.to(true) }
      it { expect { parse_payload }.to change { task.outcome }.to({ 'error' => 'encoding_mismatch' }) }
      it { is_expected.to be false }
    end

    context 'when data encoded with the wrong keys is sent' do
      let(:request_hash) do
        {
          first_name: 'fname',
          malicious_name: 'lname',
          dob: '1990-01-01',
          nino: 'QQ123456C',
          from: '2020-01-01',
          to: '2020-04-01'
        }
      end
      it { expect { parse_payload }.to change { task.completed? }.to(true) }
      it { expect { parse_payload }.to change { task.errored? }.to(true) }
      it { expect { parse_payload }.to change { task.outcome }.to({ 'error' => 'json_schema_mismatch' }) }
      it { is_expected.to be false }
    end
  end

  describe '#call' do
    subject(:call) { task.call }

    it { expect { call }.to change { task.in_progress? }.from(false).to(true) }
  end

  def create_jwt_with(payload, secret)
    JWT.encode payload, secret, 'HS512'
  end
end

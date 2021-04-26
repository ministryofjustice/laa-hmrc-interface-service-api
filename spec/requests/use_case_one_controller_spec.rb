require 'rails_helper'

describe UseCaseOneController, type: :request do
  describe 'POST /use_case_one' do
    subject(:post_uc1) { post use_case_one_index_path, params: params, headers: headers }
    let(:headers) { { authorization: access_key } }
    let(:params) { { data: jwt } }
    let(:application_user) { create :application_user }
    let(:access_key) { application_user.access_key }
    let(:jwt) { create_jwt_with(request_hash, application_user.secret_key) }
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
    before { post_uc1 }

    describe 'unauthorized checks' do
      context 'when no params are sent' do
        let(:params) { nil }

        it 'returns unauthorized' do
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'when no access_key is sent' do
        let(:access_key) { '' }

        it 'returns unauthorized' do
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'when nil access_key is sent' do
        let(:access_key) { nil }

        it 'returns unauthorized' do
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'when no data is sent' do
        let(:jwt) { '' }

        it 'returns unauthorized' do
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'when nil data is sent' do
        let(:jwt) { nil }

        it 'returns unauthorized' do
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'when data encoded with the wrong key is sent' do
        let(:jwt) { create_jwt_with(request_hash, 'incorrect_secret_key') }

        it 'returns unauthorized' do
          expect(response).to have_http_status(:unauthorized)
        end
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

        it 'returns unauthorized' do
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'when the application_user does not have the correct use_case' do
        let(:application_user) { create :application_user, use_cases: [2] }

        it 'returns unauthorized' do
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    it 'returns success' do
      expect(response).to have_http_status(:success)
    end
  end

  def create_jwt_with(payload, secret)
    JWT.encode payload, secret, 'HS512'
  end
end

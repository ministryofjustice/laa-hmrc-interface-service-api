require "rails_helper"

RSpec.describe StatusController, type: :request do
  describe "#healthcheck" do
    before do
      allow(Sidekiq::ProcessSet).to receive(:new).and_return(instance_double(Sidekiq::ProcessSet, size: 1))
      allow(Sidekiq::RetrySet).to receive(:new).and_return(instance_double(Sidekiq::RetrySet, size: 0))
      allow(Sidekiq::DeadSet).to receive(:new).and_return(instance_double(Sidekiq::DeadSet, size: 0))
    end

    context "when an postgres problem exists" do
      before do
        allow(ActiveRecord::Base.connection).to receive(:active?).and_raise(PG::ConnectionBad)

        get "/health_check"
      end

      let(:failed_healthcheck) do
        {
          checks: {
            database: false,
            redis: true,
            sidekiq: true,
            sidekiq_queue: true,
          },
        }.to_json
      end

      it "returns status bad gateway" do
        expect(response).to have_http_status :bad_gateway
      end

      it "returns the expected response report" do
        expect(response.body).to eq(failed_healthcheck)
      end
    end

    context "when a redis problem exists" do
      before do
        allow(REDIS).to receive(:ping).and_raise(Redis::CannotConnectError)

        get "/health_check"
      end

      let(:failed_healthcheck) do
        {
          checks: {
            database: true,
            redis: false,
            sidekiq: true,
            sidekiq_queue: true,
          },
        }.to_json
      end

      it "returns status bad gateway" do
        expect(response).to have_http_status :bad_gateway
      end

      it "returns the expected response report" do
        expect(response.body).to eq(failed_healthcheck)
      end
    end

    context "when a sidekiq problem exists" do
      before do
        allow(REDIS).to receive(:ping).and_raise(Redis::CannotConnectError)
        allow(Sidekiq::ProcessSet).to receive(:new).and_return(instance_double(Sidekiq::ProcessSet, size: 0))

        connection = instance_double("connection")
        allow(connection).to receive(:info).and_raise(Redis::CannotConnectError)
        allow(Sidekiq).to receive(:redis).and_yield(connection)

        get "/health_check"
      end

      let(:failed_healthcheck) do
        {
          checks: {
            database: true,
            redis: false,
            sidekiq: false,
            sidekiq_queue: true,
          },
        }.to_json
      end

      it "returns status bad gateway" do
        expect(response).to have_http_status :bad_gateway
      end

      it "returns the expected response report" do
        expect(response.body).to eq(failed_healthcheck)
      end
    end

    context "when failed Sidekiq jobs exist" do
      let(:failed_job_health_check) do
        {
          checks: {
            database: true,
            redis: true,
            sidekiq: true,
            sidekiq_queue: false,
          },
        }.to_json
      end

      context "and dead set exists" do
        before do
          allow(Sidekiq::DeadSet).to receive(:new).and_return(instance_double(Sidekiq::DeadSet, size: 1))
          get "/health_check"
        end

        it "returns ok http status" do
          expect(response).to have_http_status :ok
        end

        it "returns the expected response report" do
          expect(response.body).to eq(failed_job_health_check)
        end
      end

      context "and retry set exists" do
        before do
          allow(Sidekiq::RetrySet).to receive(:new).and_return(instance_double(Sidekiq::RetrySet, size: 1))
          get "/health_check"
        end

        it "returns ok http status" do
          expect(response).to have_http_status :ok
        end

        it "returns the expected response report" do
          expect(response.body).to eq(failed_job_health_check)
        end
      end
    end

    context "when Sidekiq::ProcessSet encounters an error" do
      before do
        allow(Sidekiq::ProcessSet).to receive(:new).and_raise(StandardError)

        get "/health_check"
      end

      let(:failed_health_check) do
        {
          checks: {
            database: true,
            redis: true,
            sidekiq: false,
            sidekiq_queue: true,
          },
        }.to_json
      end

      it "returns status bad gateway" do
        expect(response).to have_http_status :bad_gateway
      end

      it "returns the expected response report" do
        expect(response.body).to eq(failed_health_check)
      end
    end

    context "when sidekiq_queue_healthy encounters an error" do
      before do
        allow(Sidekiq::DeadSet).to receive(:new).and_raise(StandardError)

        get "/health_check"
      end

      let(:failed_health_check) do
        {
          checks: {
            database: true,
            redis: true,
            sidekiq: true,
            sidekiq_queue: false,
          },
        }.to_json
      end

      it "returns ok http status" do
        # queue health should not impact the status
        expect(response).to have_http_status :ok
      end

      it "returns the expected response report" do
        expect(response.body).to eq(failed_health_check)
      end
    end

    context "when everything is ok" do
      before do
        allow(ActiveRecord::Base.connection).to receive(:active?).and_return(true)

        get "/health_check"
      end

      let(:expected_response) do
        {
          checks: {
            database: true,
            redis: true,
            sidekiq: true,
            sidekiq_queue: true,
          },
        }.to_json
      end

      it "returns HTTP success" do
        get "/health_check"
        expect(response.status).to eq(200)
      end

      it "returns the expected response report" do
        get "/health_check"
        expect(response.body).to eq(expected_response)
      end
    end
  end

  describe "#ping" do
    context "when environment variables set" do
      let(:expected_json) do
        {
          "build_date" => "20150721",
          "build_tag" => "test",
          "app_branch" => "test_branch",
        }
      end

      before do
        allow(Settings.status).to receive(:build_date).and_return("20150721")
        allow(Settings.status).to receive(:build_tag).and_return("test")
        allow(Settings.status).to receive(:app_branch).and_return("test_branch")

        get("/ping")
      end

      it "returns JSON with app information" do
        expect(JSON.parse(response.body)).to eq(expected_json)
      end
    end

    context "when environment variables not set" do
      before do
        allow(Settings.status).to receive(:build_date).and_return("Not Available")
        allow(Settings.status).to receive(:build_tag).and_return("Not Available")
        allow(Settings.status).to receive(:app_branch).and_return("Not Available")

        get "/ping"
      end

      it 'returns "Not Available"' do
        expect(JSON.parse(response.body).values).to be_all("Not Available")
      end
    end
  end
end

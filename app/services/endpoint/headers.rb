module Endpoint
  class Headers
    def initialize(href, correlation_id, token)
      @href = href
      @correlation_id = correlation_id
      @token = token
    end

    def call
      result = base_headers
      result.merge!(@href.include?("benefits-and-credits") ? v1_headers : v2_headers)
      result.merge!(content_type) if @href.match?(%r{individuals/matching$})
      result
    end

    def self.call(href, correlation_id, token)
      new(href, correlation_id, token).call
    end

  private

    def base_headers
      {
        correlationId: @correlation_id.to_s,
        Authorization: "Bearer #{@token}",
      }
    end

    def content_type
      { content_type: "application/json" }
    end

    def v1_headers
      { accept: "application/vnd.hmrc.1.0+json" }
    end

    def v2_headers
      { accept: "application/vnd.hmrc.2.0+json" }
    end
  end
end

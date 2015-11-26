require 'faraday'
require 'faraday_middleware'
require 'faraday/panoptes'

module Nero
  module Output
    class PanoptesApi
      attr_reader :client

      def initialize(url, client_id, client_secret)
        @client = Faraday.new(url: url) do |faraday|
          faraday.request :panoptes_client_credentials, url: url, client_id: client_id, client_secret: client_secret
          faraday.request :panoptes_api_v1
          faraday.request :json
          faraday.response :json
          faraday.adapter Faraday.default_adapter
        end
      end

      def retire(estimate)
        client.post "/api/workflows/#{estimate.workflow_id}/links/retired_subjects",
          admin: true,
          retired_subjects: [estimate.subject_id]
      end
    end
  end
end

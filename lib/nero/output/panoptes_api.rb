require 'panoptes/client'

module Nero
  module Output
    class PanoptesApi
      attr_reader :client

      def initialize(url, client_id, client_secret)
        @client = Panoptes::Client.new(url: url, auth: {client_id: client_id, client_secret: client_secret})
      end

      def retire(estimate)
        client.retire_subject(estimate.workflow_id, estimate.subject_id)
      end
    end
  end
end

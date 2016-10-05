require 'panoptes/client'

module Nero
  module Output
    class PanoptesApi
      attr_reader :client

      def initialize(url, client_id, client_secret)
        @client = Panoptes::Client.new(url: url, auth: {client_id: client_id, client_secret: client_secret})
      end

      def retire(subject_state, reason: "other")
        client.retire_subject(subject_state.workflow_id, subject_state.subject_id, reason: reason)
      end

      def add_subjects_to_subject_set(subject_set_id, subject_ids)
        client.add_subjects_to_subject_set(subject_set_id, subject_ids)
      end
    end
  end
end

require_relative 'base_repository'

module Nero
  module Repositories
    class EssenceRepository < BaseRepository
      def find(id)
        db[:classifications].where(id: id).first
      end

      def update_cache(classification_hash)
        upsert(classification_hash.fetch("id"),
               project_id: classification_hash.fetch("links").fetch("project"),
               workflow_id: classification_hash.fetch("links").fetch("workflow"),
               user_id: classification_hash.fetch("links").fetch("user"),
               subject_id: classification_hash.fetch("links").fetch("subjects").first,
               annotations: classification_hash.fetch("annotations"),
               metadata: classification_hash.fetch("metadata"))
      end

      def upsert(id, attributes={})
        attributes[:data] = Sequel.pg_jsonb(attributes[:data])

        db[:essences]
          .insert_conflict(target: :id, update: attributes)
          .insert(attributes.merge(id: id))
      end
    end
  end
end

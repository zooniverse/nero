require_relative 'base_repository'

module Nero
  module Repositories
    class SubjectRepository < BaseRepository
      def find(id)
        db[:subjects].where(id: id).first
      end

      def update_caches(subject_hashes)
        subject_hashes.each do |subject_hash|
          upsert(subject_hash.fetch("id"),
                 metadata: subject_hash.fetch("metadata"))
        end
      end

      def upsert(id, attributes={})
        attributes[:metadata] = Sequel.pg_jsonb(attributes[:metadata])

        db[:subjects]
          .insert_conflict(target: :id, update: attributes)
          .insert(attributes.merge(id: id))
      end
    end
  end
end

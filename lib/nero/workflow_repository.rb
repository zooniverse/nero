module Nero
  class WorkflowRepository < Repository
    def find(id)
      db[:workflows].where(id: id).first
    end

    def update_caches(workflow_hashes)
      workflow_hashes.each do |workflow_hash|
        upsert(workflow_hash.fetch("id"),
               project_id: workflow_hash.fetch("links").fetch("project"),
               rules: workflow_hash.fetch("retirement"))
      end
    end

    def upsert(id, attributes={})
      attributes[:rules] = Sequel.pg_jsonb(attributes[:rules])

      db[:workflows]
        .insert_conflict(target: :id, update: attributes)
        .insert(attributes.merge(id: id))
    end
  end
end

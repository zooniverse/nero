require 'sequel'
Sequel.extension :migration
Sequel.extension :pg_json
Sequel.extension :pg_json_ops

module Nero
  class Storage
    attr_reader :db

    def self.migrate(db)
      Sequel::Migrator.run(db, File.expand_path("../../../db/migrations", __FILE__))
    end

    def initialize(db)
      @db = db
      self.class.migrate(db)
    end

    def find_agent(user_id)
      record = db[:agents].where(external_id: user_id).order(:id).first

      if record
        Agent.new(id: record[:id], external_id: record[:external_id], data: JSON.load(record[:data]))
      else
        Agent.new(id: nil, external_id: user_id)
      end
    end

    def record_agent(agent)
      record = agent.attributes.dup
      record[:data] = JSON.dump(record[:data])

      if agent.id
        db[:agents].where(id: agent.id).update(record.merge(updated_at: Time.now))
      else
        db[:agents].insert(record.merge(created_at: Time.now, updated_at: Time.now))
      end
    end

    def find_estimate(subject_id, workflow_id)
      record = db[:estimates].where(subject_id: subject_id, workflow_id: workflow_id).order(:id).last

      if record
        Estimate.new(id: record[:id], subject_id: subject_id, workflow_id: workflow_id, data: JSON.load(record[:data]))
      else
        Estimate.new(id: nil, subject_id: subject_id, workflow_id: workflow_id)
      end
    end

    def record_estimate(estimate)
      record = estimate.attributes.dup
      record[:data] = JSON.dump(record[:data])

      if estimate.id
        db[:estimates].where(id: estimate.id).update(record.merge(updated_at: Time.now))
      else
        db[:estimates].insert(record.merge(created_at: Time.now, updated_at: Time.now))
      end
    end
  end
end

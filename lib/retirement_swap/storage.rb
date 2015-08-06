require 'sequel'
Sequel.extension :migration

module RetirementSwap
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
        Agent.new(**record)
      else
        Agent.new(id: nil, external_id: user_id)
      end
    end

    def record_agent(agent)
      if agent.id
        db[:agents].where(id: agent.id).update(agent.attributes)
      else
        db[:agents].insert(agent.attributes)
      end
    end

    def find_estimate(subject_id, workflow_id)
      record = db[:estimates].where(subject_id: subject_id, workflow_id: workflow_id).order(:id).last

      if record
        RetirementSwap::Estimate.new(subject_id, workflow_id, nil, nil, record[:probability])
      else
        RetirementSwap::Estimate.new(subject_id, workflow_id)
      end
    end

    def record_estimate(estimate)
      db[:estimates].insert(estimate.attributes)
    end
  end
end

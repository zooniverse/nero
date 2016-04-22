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

    def find_user_state(user_id)
      record = db[:agents].where(external_id: user_id).order(:id).first

      if record
        UserState.new(id: record[:id], external_id: record[:external_id], data: record[:data])
      else
        UserState.new(id: nil, external_id: user_id)
      end
    end

    def record_user_state(user_state)
      record = user_state.attributes.dup
      record[:data] = Sequel.pg_jsonb(record[:data])

      if user_state.id
        db[:agents].where(id: user_state.id).update(record.merge(updated_at: Time.now))
      else
        db[:agents].insert(record.merge(created_at: Time.now, updated_at: Time.now))
      end
    end

    def find_subject_state(subject_id, workflow_id)
      record = db[:estimates].where(subject_id: subject_id, workflow_id: workflow_id).order(:id).last

      if record
        SubjectState.new(id: record[:id], subject_id: subject_id, workflow_id: workflow_id, data: record[:data])
      else
        SubjectState.new(id: nil, subject_id: subject_id, workflow_id: workflow_id)
      end
    end

    def record_subject_state(subject_state)
      record = subject_state.attributes.dup
      record[:data] = Sequel.pg_jsonb(record[:data])

      if subject_state.id
        db[:estimates].where(id: subject_state.id).update(record.merge(updated_at: Time.now))
      else
        db[:estimates].insert(record.merge(created_at: Time.now, updated_at: Time.now))
      end
    end
  end
end

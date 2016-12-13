Sequel.migration do
  change do
    create_table :essences do
      primary_key :id
      integer :classification_id
      integer :extractor_id

      integer :project_id
      integer :workflow_id
      integer :user_id
      integer :subject_id

      jsonb :data
    end
  end
end

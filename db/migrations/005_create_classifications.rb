Sequel.migration do
  change do
    create_table :classifications do
      primary_key :id

      integer :project_id
      integer :workflow_id
      integer :user_id
      integer :subject_id

      jsonb :annotations
      jsonb :metadata
    end
  end
end

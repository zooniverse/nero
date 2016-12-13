Sequel.migration do
  change do
    create_table :reductions do
      primary_key :id
      integer :reducer_id

      integer :project_id
      integer :workflow_id
      integer :subject_id

      jsonb :data
    end
  end
end

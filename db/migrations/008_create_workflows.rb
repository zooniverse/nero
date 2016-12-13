Sequel.migration do
  change do
    create_table :workflows do
      primary_key :id
      integer :project_id

      jsonb :rules
    end
  end
end

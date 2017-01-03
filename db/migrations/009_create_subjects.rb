Sequel.migration do
  change do
    create_table :subjects do
      primary_key :id
      jsonb :metadata
    end
  end
end

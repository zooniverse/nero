Sequel.migration do
  change do
    add_column :agents, :created_at, DateTime
    add_column :agents, :updated_at, DateTime

    add_column :estimates, :created_at, DateTime
    add_column :estimates, :updated_at, DateTime
  end
end

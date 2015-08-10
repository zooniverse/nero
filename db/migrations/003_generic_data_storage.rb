Sequel.migration do
  change do
    add_column :agents, :data, :jsonb, text: true
    add_column :estimates, :data, :jsonb, text: true
  end
end

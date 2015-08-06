Sequel.migration do
  change do
    add_column :agents,    :data, String, text: true
    add_column :estimates, :data, String, text: true
  end
end

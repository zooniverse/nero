Sequel.migration do
  change do
    drop_table? :agents
  end
end

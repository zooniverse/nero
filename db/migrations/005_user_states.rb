Sequel.migration do
  change do
    create_table :user_states do
      primary_key :id
      String :workflow_id, null: false
      String :user_id,     null: false
      jsonb  :data

      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      index [:workflow_id, :user_id], unique: true
    end
  end
end

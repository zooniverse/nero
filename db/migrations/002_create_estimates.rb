Sequel.migration do
  change do
    create_table :estimates do
      primary_key :id
      String :subject_id
      String :workflow_id
      String :user_id
      String :answer
      Float :probability

      index [:subject_id, :workflow_id]
    end
  end
end

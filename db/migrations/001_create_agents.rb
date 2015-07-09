Sequel.migration do
  change do
    create_table :agents do
      primary_key :id
      String :external_id, index: true, null: false
      Float :pl
      Float :pd
      Float :contribution
      Integer :counts_lens
      Integer :counts_duds
      Integer :counts_test
      Integer :counts_total
    end
  end
end

require 'spec_helper'

describe Nero::Storage do
  let(:db) { DB }
  let(:storage) { described_class.new(db) }

  before do
    described_class.migrate(db)
  end

  context 'user_states' do
    it 'returns a new user_state for an unknown user id' do
      user_state = storage.find_user_state('123')
      expect(user_state.id).to be_nil
      expect(user_state.external_id).to eq('123')
    end

    it 'stores and retrieves user_states' do
      user_state = storage.find_user_state('123')
      user_state.data["foo"] = "bar"
      storage.record_user_state(user_state)
      retrieved_user_state = storage.find_user_state('123')

      expect(retrieved_user_state.id).not_to be_nil
      expect(retrieved_user_state.external_id).to eq('123')
      expect(retrieved_user_state.data["foo"]).to eq("bar")
    end
  end

  context 'estimates' do
    it 'returns a default estimate for unknown subject/workflows' do
      estimate = storage.find_estimate('1', '2')
      expect(estimate.id).to be_nil
      expect(estimate.subject_id).to eq('1')
      expect(estimate.workflow_id).to eq('2')
    end

    it 'finds the latest estimate' do
      db[:estimates].insert(subject_id: '1', workflow_id: '2', data: JSON.dump({a: 1}))
      estimate = storage.find_estimate('1', '2')
      expect(estimate.data).to eq({'a' => 1})
    end

    it 'stores estimates' do
      db[:estimates].insert(subject_id: '1', workflow_id: '2')
      estimate = storage.find_estimate('1', '2')
      estimate.data["foo"] = "bar"
      storage.record_estimate(estimate)

      retrieved_estimate = storage.find_estimate('1', '2')
      expect(retrieved_estimate.data["foo"]).to eq("bar")
    end
  end
end

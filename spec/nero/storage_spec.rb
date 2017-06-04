require 'spec_helper'

describe Nero::Storage do
  let(:db) { DB }
  let(:storage) { described_class.new(db) }

  before do
    described_class.migrate(db)
  end

  context 'user_states' do
    let(:user_id) { '123' }
    let(:workflow_id) { '2' }

    it 'returns a new user_state for an unknown user id' do
      user_state = storage.find_user_state(user_id, workflow_id)
      expect(user_state.id).to be_nil
      expect(user_state.user_id).to eq(user_id)
    end

    it 'stores and retrieves user_states' do
      user_state = storage.find_user_state(user_id, workflow_id)
      user_state.data["foo"] = "bar"
      storage.record_user_state(user_state)
      retrieved_user_state = storage.find_user_state(user_id, workflow_id)

      expect(retrieved_user_state.id).not_to be_nil
      expect(retrieved_user_state.user_id).to eq(user_id)
      expect(retrieved_user_state.workflow_id).to eq(workflow_id)

      expect(retrieved_user_state.data["foo"]).to eq("bar")
    end
  end

  context 'subject_states' do
    it 'returns a default subject_state for unknown subject/workflows' do
      subject_state = storage.find_subject_state('1', '2')
      expect(subject_state.id).to be_nil
      expect(subject_state.subject_id).to eq('1')
      expect(subject_state.workflow_id).to eq('2')
    end

    it 'finds the latest subject_state' do
      db[:estimates].insert(subject_id: '1', workflow_id: '2', data: JSON.dump({a: 1}))
      subject_state = storage.find_subject_state('1', '2')
      expect(subject_state.data).to eq({'a' => 1})
    end

    it 'stores subject_states' do
      db[:estimates].insert(subject_id: '1', workflow_id: '2')
      subject_state = storage.find_subject_state('1', '2')
      subject_state.data["foo"] = "bar"
      storage.record_subject_state(subject_state)

      retrieved_subject_state = storage.find_subject_state('1', '2')
      expect(retrieved_subject_state.data["foo"]).to eq("bar")
    end
  end
end

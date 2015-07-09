require 'spec_helper'

describe RetirementSwap::Storage::Database do
  let(:db) { Sequel.sqlite }
  let(:storage) { described_class.new(db) }

  before do
    described_class.migrate(db)
  end

  context 'agents' do
    it 'returns a new agent for an unknown user id' do
      agent = storage.find_agent('123')
      expect(agent.id).to be_nil
      expect(agent.external_id).to eq('123')
    end

    it 'stores and retrieves agents' do
      agent = storage.find_agent('123')
      agent.update_confusion_unsupervised('LENS', 0.5)
      storage.record_agent(agent)
      retrieved_agent = storage.find_agent('123')

      expect(retrieved_agent.id).not_to be_nil
      expect(retrieved_agent.external_id).to eq('123')
      expect(retrieved_agent.pl).to eq(agent.pl)
    end
  end

  context 'estimates' do
    it 'returns a default estimate for unknown subject/workflows' do
      estimate = storage.find_estimate('1', '2')
      expect(estimate.probability).to eq(RetirementSwap::Estimate::INITIAL_PRIOR)
    end

    it 'finds the latest estimate' do
      db[:estimates].insert(subject_id: '1', workflow_id: '2', probability: 0.8)
      estimate = storage.find_estimate('1', '2')
      expect(estimate.probability).to eq(0.8)
    end

    it 'stores estimates as new records' do
      db[:estimates].insert(subject_id: '1', workflow_id: '2', probability: 0.8)
      estimate = storage.find_estimate('1', '2')
      new_estimate = estimate.adjust(double(pl: 0.5, pd: 0.5, external_id: '123'), 'LENS')
      storage.record_estimate(new_estimate)
      expect(db[:estimates].count).to eq(2)
    end
  end
end

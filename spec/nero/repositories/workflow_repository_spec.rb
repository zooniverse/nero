require 'spec_helper'

describe Nero::Repositories::WorkflowRepository do
  let(:db) { DB }

  before do
    Nero::Storage.migrate(db)
  end

  let(:repo) { described_class.new(db) }

  describe 'find' do
    it 'finds a workflow' do
      repo.upsert(1, {rules: {a: 1}})
      expect(repo.find(1)).to eq(id: 1, project_id: nil, rules: {"a" => 1})
    end
  end

  describe 'update_caches' do
    it 'upserts multiple records' do
      repo.update_caches([{"id" => 1, "retirement" => {}, "links" => {"project" => 1}},
                          {"id" => 2, "retirement" => {}, "links" => {"project" => 1}}])
      expect(db[:workflows].count).to eq(2)
    end
  end

  context 'upsert' do
    it 'inserts a new workflow' do
      repo.upsert(1, {rules: {a: 1}})
      expect(db[:workflows].first).to eq(id: 1, project_id: nil, rules: {"a" => 1})
    end

    it 'updates an existing workflow' do
      repo.upsert(1, {rules: {a: 1}})
      repo.upsert(1, {rules: {a: 2}})
      expect(db[:workflows].first).to eq(id: 1, project_id: nil, rules: {"a" => 2})
    end
  end
end

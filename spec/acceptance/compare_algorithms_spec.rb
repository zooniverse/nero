require 'spec_helper'

require 'json'
require 'mongo'
require 'pry'

Mongo::Logger.logger.level = Logger::FATAL

require 'swapr/process_batch'

describe 'Compare SWAPR vs RetirementSwap' do
  let(:swapr) { ProcessBatch.new }
  let(:storage) { RetirementSwap::Storage::Memory.new }
  let(:output) { RetirementSwap::Output::IOWriter.new(STDOUT) }
  let(:retirement_swap) { RetirementSwap::SwapAlgorithm.new(storage, output) }

  it 'is the same' do
    start_from = Time.new(2014, 1, 9)
    total_to_do  = (ENV["AMOUNT"] || 1000000).to_i

    db = Mongo::Client.new(['127.0.0.1:27017'], database: 'ourobouros_spacewarp')
    spacewarp_classifications = db["spacewarp_classifications"]
    spacewarp_subjects = db["spacewarp_subjects"]

    counter = 0
    spacewarp_classifications.find({:created_at => {:$gt => start_from}}).sort(:created_at => 1).limit(total_to_do).each do |classification|
      counter += 1
      puts counter if counter % 1000 == 0

      subjects = classification["subject_ids"].map do |id|
        hash = spacewarp_subjects.find({:_id => id}).first.to_h
        [id, hash]
      end

      swapr_classification = classification

      retirement_classification = {
        'id' => classification["_id"].to_s,
        'annotations' => classification["annotations"],
        'subjects' => Hash[subjects],
        'links' => {'project' => classification["project_id"].to_s,
                'user' => (classification["user_id"] || classification["user_ip"]).to_s,
                'workflow' => classification["workflow_id"].to_s,
                'subjects' => classification["subject_ids"].map(&:to_s)}
      }

      swapr_result = swapr.process(swapr_classification)
      retir_result = retirement_swap.process(retirement_classification).first.probability

      # binding.pry unless retir_result == swapr_result

      expect(retir_result).to eq(swapr_result)
    end
  end
end

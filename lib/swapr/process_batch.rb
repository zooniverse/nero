ENV["MONGOID_ENV"] = 'development'

require 'mongoid'
Mongoid.load!(File.expand_path('../mongoid.yml', __FILE__))

require_relative 'models'

class ProcessBatch
  attr_reader :space_warp_classifications, :space_warp_subjects

  def initialize
    ouroboros = Mongo::Client.new(['127.0.0.1:27017'], database: 'ourobouros_spacewarp')
    @space_warp_classifications = ouroboros["spacewarp_classifications"]
    @space_warp_subjects        = ouroboros["spacewarp_subjects"]

    group_ids = {"5154a3783ae74086ab000001" => "subject", "5154a3783ae74086ab000002"=> "sim"}

    SwaprAgent.delete_all
    SwaprSubject.delete_all

    @classifications = []
    @agents = {}
    @subjects = {}
  end

  def find_agent(id)
    @agents[id] ||= SwaprAgentEntity.new(id)
  end

  def find_subject(id)
    @subjects[id] ||= SwaprSubjectEntity.new(id)
  end

  def run
    skip_count   = 0
    start_from   = Time.new(2014, 1, 9)
    total_to_do  = (ENV["AMOUNT"] || 1000000).to_i

    space_warp_classifications.find({:created_at => {:$gt => start_from}}).sort(:created_at => 1).limit(total_to_do).each do |classification|
      process(classification)
    end

    persist_agents
    persist_subjects
  end

  def process(classification)
    user_id  = (classification["user_id"] || classification["user_ip"]).to_s
    subject  = find_subject(classification["subject_ids"].first.to_s)

    if subject.status!="active" and subject.category=='test'
      return subject.probability
    end

    if subject.kind == "unknown"
      ouroboros_subject = space_warp_subjects.find({:_id => classification["subject_ids"].first}).first
      training = ouroboros_subject["metadata"]["training"]

      if training and training.count >0 and training.first["type"]
        if ["lensing cluster", "lensed quasar", "lensed galaxy"].include? training.first["type"]
          subject.category = 'training'
          subject.kind     = 'sim'
        elsif  training.first["type"] == "empty"
          subject.category = 'training'
          subject.kind     = 'dud'
        end
      else
        subject.kind ='test'
      end

      subject.url  = ouroboros_subject["location"]["standard"]
      subject.save
    end

    agent      = find_agent(user_id)
    marker_count = classification["annotations"].select{|a| a.keys.include? "x"}.count

    case subject.category
    when "training"
      case subject.kind
      when "sim"
        if sim_found?(classification)
          mark(agent, subject, "LENS")
        else
          mark(agent, subject, "NOT")
        end
      when "dud"
        if marker_count > 0
          mark(agent, subject, "LENS")
        else
          mark(agent, subject, "NOT")
        end
      end
    when "test"
      if marker_count > 0
        mark(agent, subject, "LENS")
      else
        mark(agent, subject, "NOT")
      end
    end

    subject.probability
  end

  def sim_found?(classification)
    sims_found = classification["annotations"].select { |a| a.keys.include? "simFound" }
    sims_found.first && sims_found.first["simFound"] == "true"
  end

  def mark(agent, subject, user_said)
    subject.update_prob(agent, user_said) unless subject.category == "training" && subject.status != "active"
    agent.update_confusion_unsupervised(user_said, subject.probability)
    @classifications << {user_id: agent.user_id, answer: user_said, subject_id: subject.ouroboros_subject_id, probability: subject.probability}
  end

  def persist_agents
    puts "Persisting #{@agents.size} agents"

    if ENV["GOLDENMASTER"]
      File.open("agents.json", 'w') { |f| JSON.dump(@agents, f) }
    else
      @agents.each do |_, agent|
        record = Agent.find_or_create_by(user_id: agent.user_id)
        record.update_attributes! \
          pl:           agent.pl,
          pd:           agent.pd,
          contribution: agent.contribution,
          counts:       agent.counts,
          history:      agent.history
        print '.'
      end
    end
    print "\n"
  end

  def persist_subjects
    puts "Persisting #{@subjects.size} subjects"

    if ENV["GOLDENMASTER"]
      File.open("subjects.json", 'w') { |f| JSON.dump(@subjects, f) }
      require 'csv'

      CSV.open("estimates.csv", "wb") do |csv|
        @subjects.each do |_, subject|
          csv << [subject.ouroboros_subject_id, nil, subject.probability]
        end
      end
    else
      @subjects.each do |_, subject|
        record = Subject.find_or_create_by(ouroboros_subject_id: subject.ouroboros_subject_id)
        record.update_attributes! \
          classification_count: subject.classification_count,
          kind: subject.kind,
          category: subject.category,
          status: subject.status,
          trajectory: subject.trajectory,
          probability: subject.probability,
          url: subject.url
        print '.'
      end
    end
    print "\n"
  end
end


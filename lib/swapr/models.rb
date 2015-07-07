require 'mongoid'

InitalPrior= 2e-4
Inital_pl = 0.5
Inital_pd = 0.5

class SwaprSubject
  include Mongoid::Document

  field :ouroboros_subject_id, type: String

  field :classification_count,  type: Float,  default: 0.0

  field :kind,                  type: String, default: "unknown"
  field :category,              type: String, default: "test"
  field :status,                type: String, default: "active"
  field :trajectory,            type: Array,  default: [InitalPrior]
  field :probability,           type: Float,  default: InitalPrior
  field :url,                   type: String

  index "ourobors_subject_id" => 1
end

class SwaprAgent
  include Mongoid::Document
  # field :id , type: Moped::BSON::ObjectId
  field :user_id,      type: String, default: nil
  field :pl,           type: Float,  default: Inital_pl
  field :pd,           type: Float,  default: Inital_pd

  field :contribution, type: Float,  default: 0

  field :counts,       type: Hash,   default: {"lens" => 0, "duds" =>0, "test" => 0, "total" => 0}
  field :history,      type: Array,  default: [{"pl" =>Inital_pl, "pd" => Inital_pd, "info" => 0}]

  index "user_id" => 1
end

require 'mongoid'

class SwaprAgentEntity
  def initialize(id)
    @user_id = id
    @pl = Inital_pl
    @pd = Inital_pd
    @contribution = 0.0
    @counts = {"lens" => 0, "duds" =>0, "test" => 0, "total" => 0}
    @history = [{"pl" =>Inital_pl, "pd" => Inital_pd, "info" => 0}]
  end

  attr_accessor :user_id
  attr_accessor :pl
  attr_accessor :pd
  attr_accessor :contribution
  attr_accessor :counts
  attr_accessor :history

  def update_contribution()
    plogp = [0,0]

    plogp[0] = 0.5*(pd+pl)*Math.log2(pd+pl)
    plogp[1] = 0.5*(1.0-pd+1.0-pl)*Math.log2(1.0-pd+1.0-pl)
    # set :contribution, (plogp[0] + plogp[1])
  end

  def update_confusion_unsupervised(user_said, lens_prob)
    if user_said == "LENS"
      pl_new = (pl * counts["lens"] + lens_prob)/(lens_prob+counts["lens"])
      pl_new = [pl_new,pl_max].min
      pl_new = [pl_new,pl_min].max
      @pl = pl_new


      pd_new = (pd*counts["lens"] )/((1-lens_prob)+counts["duds"])
      pd_new = [pd_new,pd_max].min
      pd_new = [pd_new,pd_min].max
      @pd = pd_new

      @counts["lens"] += 1
      @counts["total"] += 1
    else

      pl_new = (pl*counts["lens"])/(lens_prob+counts["lens"])
      pl_new = [pl_new,pl_max].min
      pl_new = [pl_new,pl_min].max
      @pl = pl_new

      pd_new = (pd*counts["duds"] + (1-lens_prob))/((lens_prob-1)+counts["duds"])
      pd_new = [pd_new,pd_max].min
      pd_new = [pd_new,pd_min].max
      @pd = pd_new

      @counts["duds"] += 1
      @counts["total"] += 1
    end
  end

  def update_confusion(user_said, actual)
    if user_said=="LENS" and actual=="sim"
      match = 1
    elsif user_said =="NOT" and actual =="dud"
      match = 1
    else
      match = 0
    end

    if actual == "sim"
      pl_new = (pl * counts["lens"] + match)/(1+counts["lens"])
      pl_new = [pl_new,pl_max].min
      pl_new = [pl_new,pl_min].max
      @pl = pl_new

      @counts["lens"] += 1
      @counts["total"] += 1
    else

      pd_new = (pd*counts["duds"] + match)/(1+counts["duds"])
      pd_new = [pd_new,pd_max].min
      pd_new = [pd_new,pd_min].max
      @pd = pd_new

      @counts["duds"] += 1
      @counts["total"] += 1
    end

    update_history
  end

  def update_history
    @history << {"info" => update_contribution, "pl"=> pl, "pd" => pd}
  end

  def pl_max
    0.9
  end

  def pl_min
    0.1
  end

  def pd_max
    0.9
  end

  def pd_min
    0.1
  end

  def save
  end
end

class SwaprSubjectEntity
  def initialize(id)
    @ouroboros_subject_id = id
    @classification_count = 0.0
    @kind = "unknown"
    @category = "test"
    @status = "active"
    @trajectory = [InitalPrior]
    @probability = InitalPrior
    @url = nil
  end

  attr_accessor :ouroboros_subject_id
  attr_accessor :classification_count
  attr_accessor :kind
  attr_accessor :category
  attr_accessor :status
  attr_accessor :trajectory
  attr_accessor :probability
  attr_accessor :url

  def update_prob(agent, answer)
    pl = agent.pl
    pd = agent.pd

    if answer=="LENS"
      likelihood = pl
      likelihood /= (pl*probability + (1-pd)*(1-probability))
    else
      likelihood = (1-pl)
      likelihood /= ((1-pl)*probability + pd*(1-probability))
    end

    #shouldnt have to do this ... not sure whats going on here.
    result = likelihood * probability
    @probability = result
    @trajectory << result
    @classification_count += 1

    test_retirement
  end

  def test_retirement
    @status = "rejected" if probability < rejection_threshold
    @status = "detected" if probability > detection_threshold
  end

  def rejection_threshold
    1e-07
  end

  def detection_threshold
    0.95
  end

  def save
  end
end

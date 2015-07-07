module RetirementSwap
  class Agent
    INITIAL_PL = 0.5
    INITIAL_PD = 0.5

    attr_reader :id, :pl, :pd

    def initialize(id, pl = INITIAL_PL, pd = INITIAL_PD)
      @id = id
      @pl = pl
      @pd = pd
      @contribution = 0.0
      @counts = {"lens" => 0, "duds" =>0, "test" => 0, "total" => 0}
    end

    def self.perfect
      new(1, 1)
    end

    def update_confusion_unsupervised(user_said, lens_prob)
      if user_said == "LENS"
        pl_new = (pl * @counts["lens"] + lens_prob)/(lens_prob+@counts["lens"])
        pl_new = [pl_new,pl_max].min
        pl_new = [pl_new,pl_min].max
        @pl = pl_new

        pd_new = (pd*@counts["lens"] )/((1-lens_prob)+@counts["duds"])
        pd_new = [pd_new,pd_max].min
        pd_new = [pd_new,pd_min].max
        @pd = pd_new

        @counts["lens"] += 1
        @counts["total"] += 1
      else

        pl_new = (pl*@counts["lens"])/(lens_prob+@counts["lens"])
        pl_new = [pl_new,pl_max].min
        pl_new = [pl_new,pl_min].max
        @pl = pl_new

        pd_new = (pd*@counts["duds"] + (1-lens_prob))/((lens_prob-1)+@counts["duds"])
        pd_new = [pd_new,pd_max].min
        pd_new = [pd_new,pd_min].max
        @pd = pd_new

        @counts["duds"] += 1
        @counts["total"] += 1
      end
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
  end
end

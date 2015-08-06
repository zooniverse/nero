module RetirementSwap
  class Agent
    INITIAL_PL = 0.5
    INITIAL_PD = 0.5

    attr_reader :id, :external_id, :data, :pl, :pd, :contribution, :counts_lens, :counts_duds, :counts_test, :counts_total

    def initialize(id:, external_id:, data: {}, pl: INITIAL_PL, pd: INITIAL_PD, contribution: 0.0, counts_lens: 0, counts_duds: 0, counts_test: 0, counts_total: 0)
      @id = id
      @external_id = external_id
      @data = data
      @pl = pl
      @pd = pd
      @contribution = contribution
      @counts_lens = counts_lens
      @counts_duds = counts_duds
      @counts_test = counts_test
      @counts_total = counts_total
    end

    def attributes
      {
        :external_id => external_id,
        :data => data,
        :pl => pl,
        :pd => pd,
        :contribution => contribution,
        :counts_lens => counts_lens,
        :counts_duds => counts_duds,
        :counts_test => counts_test,
        :counts_total => counts_total
      }
    end

    def skill

    end

    def update_confusion_unsupervised(user_said, lens_prob)
      if user_said == "LENS"
        pl_new = (pl * @counts_lens + lens_prob)/(lens_prob+@counts_lens)
        pl_new = [pl_new,pl_max].min
        pl_new = [pl_new,pl_min].max
        @pl = pl_new

        pd_new = (pd*@counts_lens )/((1-lens_prob)+@counts_duds)
        pd_new = [pd_new,pd_max].min
        pd_new = [pd_new,pd_min].max
        @pd = pd_new

        @counts_lens += 1
        @counts_total += 1
      else

        pl_new = (pl*@counts_lens)/(lens_prob+@counts_lens)
        pl_new = [pl_new,pl_max].min
        pl_new = [pl_new,pl_min].max
        @pl = pl_new

        pd_new = (pd*@counts_duds + (1-lens_prob))/((lens_prob-1)+@counts_duds)
        pd_new = [pd_new,pd_max].min
        pd_new = [pd_new,pd_min].max
        @pd = pd_new

        @counts_duds += 1
        @counts_total += 1
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

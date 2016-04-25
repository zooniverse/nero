module Nero
  module Swap
    class SwapUserState < SimpleDelegator
      INITIAL_PL = 0.5
      INITIAL_PD = 0.5

      PL_MIN = 0.1
      PL_MAX = 0.9
      PD_MIN = 0.1
      PD_MAX = 0.9

      def pl
        data["pl"] || INITIAL_PL
      end

      def pl=(value)
        data["pl"] = value
      end

      def pd
        data["pd"] || INITIAL_PD
      end

      def pd=(value)
        data["pd"] = value
      end

      def contribution
        data["contribution"] || 0.0
      end

      def contribution=(value)
        data["contribution"] = value
      end

      def counts_lens
        data["counts_lens"] || 0
      end

      def counts_lens=(value)
        data["counts_lens"] = value
      end

      def counts_duds
        data["counts_duds"] || 0
      end

      def counts_duds=(value)
        data["counts_duds"] = value
      end

      def counts_test
        data["counts_test"] || 0
      end

      def counts_test=(value)
        data["counts_test"] = value
      end

      def counts_total
        data["counts_total"] || 0
      end

      def counts_total=(value)
        data["counts_total"] = value
      end

      def skill(p = 0.5)
        # Special case for 0.0, because 0.0 * -Infinity => indeterminate
        s = ->(x) { x == 0.0 ? x : x * Math.log2(x) }

        parts = [
          p     * (s[pl] + s[1-pl]),
          (1-p) * (s[pd] + s[1-pd]),
          s[p * pl     + (1-p) * (1-pd)],
          s[p * (1-pl) + (1-p) * pd]
        ]

        parts[0] + parts[1] - parts[2] - parts[3]
      end

      def update_confusion_unsupervised(user_said, lens_prob)
        if user_said == "LENS"
          pl_new = (pl * counts_lens + lens_prob) / (lens_prob + counts_lens)
          pl_new = [pl_new, PL_MAX].min
          pl_new = [pl_new, PL_MIN].max
          self.pl = pl_new

          pd_new = (pd * counts_lens) / ((1 - lens_prob) + counts_duds)
          pd_new = [pd_new, PD_MAX].min
          pd_new = [pd_new, PD_MIN].max
          self.pd = pd_new

          self.counts_lens += 1
          self.counts_total += 1
        else
          pl_new = (pl * counts_lens) / (lens_prob + counts_lens)
          pl_new = [pl_new, PL_MAX].min
          pl_new = [pl_new, PL_MIN].max
          self.pl = pl_new

          pd_new = (pd * counts_duds + (1 - lens_prob)) / ((lens_prob - 1) + counts_duds)
          pd_new = [pd_new, PD_MAX].min
          pd_new = [pd_new, PD_MIN].max
          self.pd = pd_new

          self.counts_duds += 1
          self.counts_total += 1
        end
      end
    end
  end
end

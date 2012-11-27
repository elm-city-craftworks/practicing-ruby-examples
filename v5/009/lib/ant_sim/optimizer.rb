module AntSim
  class Optimizer
    BEST_CHOICE_BONUS = 3

    def initialize(here, nearby_places)
      self.here          = here
      self.nearby_places = nearby_places

      self.ahead, self.ahead_left, self.ahead_right = nearby_places
    end

    attr_reader :here, :nearby_places, :ahead, :ahead_left, :ahead_right

    def seek_home
      if here.home
        :drop_food
      elsif ahead.home && (! ahead.ant)
        :move_forward
      else
        home_ranking = rank_by { |cell| cell.home ? 1 : 0 }
        pher_ranking = rank_by { |cell| cell.home_pheremone }

        ranks = combined_ranks(home_ranking, pher_ranking)
        follow_trail(ranks)
      end
    end

    def seek_food
      if here.food > 0 && (! here.home)
        :take_food
      elsif ahead.food > 0 && (! ahead.home ) && (! ahead.ant )
        :move_forward
      else
        food_ranking = rank_by { |cell| cell.food }
        pher_ranking = rank_by { |cell| cell.food_pheremone }

        ranks = combined_ranks(food_ranking, pher_ranking)
        follow_trail(ranks)
      end
    end

    private

    attr_writer :here, :nearby_places, :ahead, :ahead_left, :ahead_right

    def follow_trail(ranks)
      choice = wrand([ ahead.ant ? 0 : ranks[ahead],
                       ranks[ahead_left],
                       ranks[ahead_right]])

      [:move_forward, :turn_left, :turn_right][choice]
    end
    
    def combined_ranks(a,b)
      combined = a.merge(b) { |k,v|  a[k] + b[k] }
      top_k, _ = combined.max_by { |k,v| v }

      combined[top_k] *= BEST_CHOICE_BONUS

      combined
    end

    def rank_by(&keyfn)
      ranks  = Hash.new { |h,k| h[k] = 0 }
      sorted = nearby_places.sort_by { |e| keyfn.call(e).to_f }

      (0...sorted.length).each { |i| ranks[sorted[i]] = i + 1 }

      ranks
    end

    def wrand(slices)
      total = slices.reduce(:+)
      r     = rand(total)

      sum   = 0

      slices.each_with_index do |e,i|
        return i if r < sum + e
        
        sum  += e
      end
    end
  end
end

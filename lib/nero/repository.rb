module Nero
  class Repository
    attr_reader :db

    def initialize(db)
      @db = db
    end
  end
end

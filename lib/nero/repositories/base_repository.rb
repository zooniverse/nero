module Nero
  module Repositories
    class BaseRepository
      attr_reader :db

      def initialize(db)
        @db = db
      end
    end
  end
end

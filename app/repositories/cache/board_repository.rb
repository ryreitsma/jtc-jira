module Cache
  class BoardRepository
    def initialize(client)
      @client = Cache::RedisClient.new
      @records = {}
    end

    def find(id)
      @records[id] ||= Board.from_cache(JSON.parse(@client.get("board.#{id}")))
    end

    def save(board)
      @client.set("board.#{board.id}", ActiveModelSerializers::SerializableResource.new(board, include: ['team.**', 'sprints']).to_json)
    end
  end
end

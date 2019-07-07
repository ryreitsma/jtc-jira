module Config
  class TeamRepository < Config::ConfigRepository
    def config_key
      :teams
    end

    def object_type
      :team
    end

    def all
      @client.get(config_key).map do |config_hash|
        Factory.for(object_type).create_from_hash(config_hash)
      end
    end

    def find_by(options)
      if options[:board_id]
        all.select{ |team| team.board_id == options[:board_id]}
      elsif options[:department_id]
        all.select{ |team| team.department.id == options[:department_id]}
      elsif options[:deployment_constraint_id]
        all.select{ |team| team.deployment_constraint.id == options[:deployment_constraint_id]}
      end
    end
  end
end

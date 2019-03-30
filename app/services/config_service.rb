class ConfigService
  def self.register_repositories
    client = Config::ConfigClient.new
    Repository.register(:team, ::Config::TeamRepository.new(client))
    Repository.register(:department, ::Config::DepartmentRepository.new(client))
    Repository.register(:deployment_constraint, ::Config::DeploymentConstraintRepository.new(client))
  end
end
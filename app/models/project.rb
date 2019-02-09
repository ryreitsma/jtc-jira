class Project
  attr_reader :key, :name, :avatars

  def initialize(key, name, avatars)
    @key, @name, @avatars = key, name, avatars
  end

  def self.from_jira(jira_project)
    new(jira_project.key, jira_project.name, jira_project.attrs['avatarUrls'])
  end
end
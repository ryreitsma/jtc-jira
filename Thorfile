require 'dotenv/load'
require_relative 'lib/command_line'
require_relative 'config/environment.rb'

class Report < Thor
  desc "last_sprint", "Report statistics on last closed sprint for specified board id"
  method_option :board_id, type: :numeric
  method_option :number_of_sprints, type: :numeric
  method_option :subteam
  def last_sprint
    command_line = CommandLine.new
    command_line.print_last_sprints(options[:board_id], options[:subteam], options[:number_of_sprints])
  end

  desc "last_sprint_from_config", "Report statistics on last closed sprint for teams from config file"
  def last_sprint_from_config
    team_config = YAML.load_file('config.yaml')
    command_line = CommandLine.new
    team_config.each do |options|
      command_line.print_last_sprints(options[:board_id], options[:subteam], 1)
    end
  end

  desc "open_sprint", "Report statistics on open sprint for specified board id"
  method_option :board_id, type: :numeric
  method_option :subteam
  def open_sprint
    command_line = CommandLine.new
    command_line.print_open_sprint(options[:board_id], options[:subteam])
  end
end

class Cache < Thor
  desc "cache data", "Extract boards from JIRA and store in Redis cache"
  def all
    # first make sure we use the Jira repositories to fetch data
    jira_client = ::Jira::JiraClient.new
    Repository.register(:board, ::Jira::BoardRepository.new(jira_client))
    Repository.register(:sprint, ::Jira::SprintRepository.new(jira_client))
    Repository.register(:issue, ::Jira::IssueRepository.new(jira_client))
    Repository.register(:epic, ::Jira::EpicRepository.new(jira_client))
    Repository.register(:project, ::Jira::ProjectRepository.new(jira_client))
    Repository.register(:team, ::Jira::TeamRepository.new(jira_client))

    teams = Repository.for(:team).all
    boards = teams.map{ |team| Repository.for(:board).find(team.board_id)}

    redis_client = ::Cache::RedisClient.new

    puts "Caching #{teams.size} teams"
    ::Cache::TeamRepository.new(redis_client).save(teams)

    board_repo = ::Cache::BoardRepository.new(redis_client)
    sprint_repo = ::Cache::SprintRepository.new(redis_client)

    boards.each do |board|
      puts "Cache board #{board.id} for team #{board.team.name}"
      board_repo.save(board)
      board.recent_sprints(6).each do |sprint|
        puts "Caching sprint #{sprint.name}"
        sprint_repo.save(sprint)
      end
    end
  end
end

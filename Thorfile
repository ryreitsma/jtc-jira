require 'dotenv/load'
require_relative 'config/environment.rb'

class Cache < Thor
  desc "cache data", "Extract boards from JIRA and store in Redis cache"
  def all
    statsd_client = StatsdClient.new
    started = Time.now

    # first make sure we use the Jira repositories to fetch data
    JiraService.register_repositories
    ConfigService.register_repositories

    teams = Repository.for(:team).all
    puts "Retrieved #{teams.size} teams"

    projects = Repository.for(:project).all
    puts "Retrieved #{projects.size} projects"
    $stdout.flush
    issue_collections = Repository.for(:issue_collection).all
    puts "Retrieved #{issue_collections.size} issue collections"
    $stdout.flush
    # for the parent epic reporting we need to cache all epics per parent epic
    ParentEpicService.new.associate_epics_to_parent_epic
    puts "Retrieved all epics for parent_epics"
    $stdout.flush
    boards = teams.map{ |team| Repository.for(:board).find(team.board_id)}

    redis_client = ::Cache::RedisClient.new
    puts "Caching #{teams.size} teams"
    ::Cache::TeamRepository.new(redis_client).save(teams)
    $stdout.flush
    puts "Caching #{projects.size} projects"
    ::Cache::ProjectRepository.new(redis_client).save(projects)
    $stdout.flush
    puts "Caching #{issue_collections.size} issue collections"
    issue_collection_repo = ::Cache::IssueCollectionRepository.new(redis_client)
    issue_collections.each{ |issue_collection| issue_collection_repo.save(issue_collection) }
    $stdout.flush
    board_repo = ::Cache::BoardRepository.new(redis_client)
    sprint_repo = ::Cache::SprintRepository.new(redis_client)
    number_of_cached_sprints = YAML.load_file(Rails.root.join('config.yml'))[:number_of_cached_sprints]

    boards.each do |board|
      next if board.nil?

      puts "Cache board #{board.id} for team #{board.team.name}"
      board_repo.save(board)
      $stdout.flush
      board.recent_sprints(number_of_cached_sprints).each do |sprint|
        puts "Caching sprint #{sprint.name}"
        sprint_repo.save(sprint)
        $stdout.flush
      end if board.is_a? ScrumBoard
    end

    statsd_client.timing('thor.cache',
      (Time.now - started) * 1000,
      tags: ["action:all"]
    )
  end
end

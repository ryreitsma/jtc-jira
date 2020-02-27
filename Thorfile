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
    begin
      teams = Repository.for(:team).all
      puts "Retrieved #{teams.size} teams"
    rescue JIRA::HTTPError => e
      puts "JIRA username: #{ENV['JIRA_USERNAME']}"
      puts "JIRA API key: #{ENV['JIRA_API_KEY']}"
      puts "JIRA HTTP error:\n#{e.message}\nResponse from JIRA:\n#{e.response.inspect}"
    end
    $stdout.flush
    boards = []
    failed_teams = []

    teams.each do |team|
      begin
        puts "Retrieving board #{team.board_id} for team #{team.name}"
        board = Repository.for(:board).find(team.board_id)
      rescue
        puts "Board #{team.board_id} for team #{team.name} not found. "
        failed_teams << team
      end

      if board.nil?
        puts "Board #{team.board_id} for team #{team.name} not found. "
        failed_teams << team
      else
        boards << board
      end
    end

    puts "Removing #{failed_teams.size} teams from teams set and continuing."
    teams = teams - failed_teams
    puts "Retrieved #{boards.size} boards for the teams"
    $stdout.flush
    projects = Repository.for(:project).all
    puts "Retrieved #{projects.size} projects"
    $stdout.flush
    quarters = Repository.for(:quarter).all
    puts "Retrieved #{quarters.size} quarters"
    $stdout.flush
    parent_epics = Repository.for(:parent_epic).all
    puts "Retrieved #{parent_epics.size} parent_epics"
    $stdout.flush


    redis_client = ::Cache::RedisClient.new
    redis_client.flushall

    puts "Redis database flushed - database size is now #{redis_client.dbsize}"
    puts "Caching #{teams.size} teams"
    ::Cache::TeamRepository.new(redis_client).save(teams)
    $stdout.flush
    puts "Caching #{projects.size} projects"
    ::Cache::ProjectRepository.new(redis_client).save(projects)
    $stdout.flush
    puts "Caching #{quarters.size} quarters"
    ::Cache::QuarterRepository.new(redis_client).save(quarters)
    $stdout.flush
    puts "Caching #{parent_epics.size} parent_epics"
    ::Cache::ParentEpicRepository.new(redis_client).save(parent_epics)
    $stdout.flush
    board_repo = ::Cache::BoardRepository.new(redis_client)
    sprint_repo = ::Cache::SprintRepository.new(redis_client)

    boards.each do |board|
      puts "Cache board #{board.id} for team #{board.team.name}"
      board_repo.save(board)
      $stdout.flush
      board.sprints_from(2019).each do |sprint|
        puts "#{board.team.name}: Caching sprint #{sprint.name}"
        sprint_repo.save(sprint)
        $stdout.flush
      end if board.is_a? ScrumBoard
    end

    Rails.cache.clear
    puts "Rails cache cleared. Caching job finished!"

    statsd_client.timing('thor.cache',
      (Time.now - started) * 1000,
      tags: ["action:all"]
    )
  end
end

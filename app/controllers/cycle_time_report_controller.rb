class CycleTimeReportController < ApplicationController
  before_action :set_dates
  before_action :set_deployment_constraint, only: [:overview, :deployment_constraint]

  def team
    @board = Repository.for(:board).find(params[:board_id])
    @report = CycleTimeReportService.new([@board], @start_date, @end_date).cycle_time_report
    @table = @report[:table]

    respond_to do |format|
      format.html { render :team }
      format.csv { send_data to_csv(@table), filename: "cycle_time_report_team_#{@board.team.name}.csv" }
      format.json { send_data @report.to_json }
    end
  end

  def deployment_constraint
    boards = @deployment_constraint.teams.map(&:board)

    @report = CycleTimeReportService.new(boards, @start_date, @end_date).cycle_time_report

    respond_to do |format|
      format.html { render :deployment_constraint }
      format.csv { send_data to_csv(@report[:table]), filename: "cycle_time_report_constraint_#{@deployment_constraint.name}.csv" }
      format.json { send_data @report.to_json }
    end
  end

  def overview
    boards = @deployment_constraint.teams.map(&:board)
    @report = CycleTimeOverviewReportService.new(boards, DateTime.new(2019, 3, 1), DateTime.now).report

    respond_to do |format|
      format.html { render :overview }
      format.csv { send_data to_csv(@report), filename: "cycle_time_report_#{@deployment_constraint.name}.csv" }
      format.json { send_data @report.to_json }
    end
  end

  private
  def set_deployment_constraint
    deployment_constraint_id = params[:deployment_constraint_id] || '1'
    @deployment_constraint = Repository.for(:deployment_constraint).find(deployment_constraint_id.to_i)
  end
end
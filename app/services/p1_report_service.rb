class P1ReportService
  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
  end

  def p1_report
    {
      closed_issues_table: closed_issues_table,
      open_issues_table: open_issues_table,
      issue_count_per_week: issue_count_per_week.to_a,
      trend_count_per_week: linear_regression_for_issue_count,
      trend_resolution_time: linear_regression_for_resolution_time,
      resolution_averages: resolution_time_moving_averages
    }
  end

  def p1_issues
    @p1_issues ||= retrieve_p1_issues
  end

  def open_p1_issues
    p1_issues.select{ |issue| !issue.closed? }
  end

  def closed_p1_issues
    p1_issues.select{ |issue| issue.closed? }
  end

  def closed_issues_table
    table = []
    header = ["Key", "Date", "Title", "Resolution time (days)"]
    table << header
    closed_p1_issues.reverse.each do |issue|
      table << [
        issue.key,
        issue.created.strftime('%Y-%m-%d'),
        issue.summary,
        issue.resolution_time&.round(2)
      ]
    end

    table
  end

  def open_issues_table
    table = []
    header = ["Key", "Date", "Title", "Assignee"]
    table << header
    open_p1_issues.reverse.each do |issue|
      table << [
        issue.key,
        issue.created.strftime('%Y-%m-%d'),
        issue.summary,
        issue.assignee
      ]
    end

    table
  end

  def issue_count_per_week
    date = @start_date
    count_per_week = {}

    loop do
      break if date > @end_date

      count_per_week[date.cweek] = 0
      date = date + 1.week
    end

    p1_issues.inject(count_per_week) do |memo, issue|
      memo[issue.created.cweek] += 1
      memo
    end
  end

  def linear_regression_for_issue_count
    data = issue_count_per_week.map do |key, value|
      { week: key, issue_count: value }
    end
    model = Eps::Regressor.new(data, target: :issue_count)

    [predict_count(model, @start_date.cweek), predict_count(model, @end_date.cweek)]
  end

  def linear_regression_for_resolution_time
    return [] if closed_p1_issues.size <= 2

    data = closed_p1_issues.map do |issue|
      { date: issue.resolution_date.to_time.to_i, resolution_time: issue.resolution_time }
    end
    model = Eps::Regressor.new(data, target: :resolution_time)

    [predict_time(model, @start_date), predict_time(model, @end_date)]
  end

  def resolution_time_moving_averages
    return [] if closed_p1_issues.size <= 2

    date =  @start_date
    moving_averages = []

    loop do
      moving_averages << [date.strftime('%Y-%m-%d'), resolution_time_moving_average_on(date)]

      date = date + 1.week
      if date >= @end_date
        moving_averages << [@end_date.strftime('%Y-%m-%d'), resolution_time_moving_average_on(@end_date)]
        break
      end
    end

    moving_averages
  end

  def resolution_time_moving_average_on(date, period = 2.weeks)
    resolution_time_array = closed_p1_issues.inject([]) do |memo, issue|
      memo << issue.resolution_time if issue.created.between?(date.end_of_day - period, date.end_of_day)
      memo
    end

    if resolution_time_array.size > 0
      resolution_time_array.inject(:+) / resolution_time_array.size.to_f
    else
      0
    end
  end

  private
  def retrieve_p1_issues
    ConfigService.register_repositories
    JiraService.register_repositories

    issues = Repository.for(:issue_collection).find(1).sorted_issues

    CacheService.register_repositories
    issues
  end

  def predict_count(model, week)
    [week, model.predict(week: week)]
  end

  def predict_time(model, date)
    [date.strftime('%Y-%m-%d'), model.predict(date: date.to_time.to_i)]
  end
end

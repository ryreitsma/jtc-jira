Rails.application.routes.draw do
  root 'cycle_time_report#deployment_constraint'
  scope :jira do
    get '/', to: 'cycle_time_report#deployment_constraint'
    resources :kpi_goals
    resources :teams, only: [:index]
    get 'sprint_report/last_sprint', to: 'sprint_report#last_sprint', as: :last_sprint_report
    get 'sprint_report/sprint', to: 'sprint_report#sprint', as: :sprint_report
    get 'portfolio_report/teams_overview', to: 'portfolio_report#teams_overview', as: :portfolio_teams
    get 'portfolio_report/export', to: 'portfolio_report#export', as: :portfolio_export
    get 'portfolio_report/epics_overview', to: 'portfolio_report#epics_overview', as: :portfolio_epics
    get 'portfolio_report/quarter_overview', to: 'portfolio_report#quarter_overview', as: :portfolio_quarter
    match 'cycle_time_report/team', to: 'cycle_time_report#team', as: :cycle_time_team, via: [:get, :post]
    match 'cycle_time_report/deployment_constraint', to: 'cycle_time_report#deployment_constraint', as: :cycle_time_deployment_constraint, via: [:get, :post]
    get 'cycle_time_report/four_week_overview', to: 'cycle_time_report#four_week_overview', as: :cycle_time_four_week_overview
    get 'cycle_time_report/two_week_overview', to: 'cycle_time_report#two_week_overview', as: :cycle_time_two_week_overview
    get 'deployment_report/overview', to: 'deployment_report#overview', as: :deployment_report
    get 'p1_report/overview', to: 'p1_report#overview', as: :p1_report
    get 'department_report/cycle_time_overview', to: 'department_report#cycle_time_overview', as: :department_cycle_time_overview
    get 'department_report/deployments_overview', to: 'department_report#deployments_overview', as: :department_deployments_overview
    get 'department_report/issues_overview', to: 'department_report#issues_overview', as: :department_issues_overview
    get 'department_report/p1s_overview', to: 'department_report#p1s_overview', as: :department_p1s_overview
    get 'department_report/kpi_overview', to: 'department_report#kpi_overview', as: :department_kpi_overview
    post 'sprint_report/refresh_data', to: 'sprint_report#refresh_data', as: :sprint_report_refresh
  end

  resources :kpi_goals
  resources :teams, only: [:index]
  get 'sprint_report/last_sprint', to: 'sprint_report#last_sprint'
  get 'portfolio_report/teams_overview', to: 'portfolio_report#teams_overview'
  get 'portfolio_report/export', to: 'portfolio_report#export'
  get 'portfolio_report/epics_overview', to: 'portfolio_report#epics_overview'
  get 'portfolio_report/quarter_overview', to: 'portfolio_report#quarter_overview'
  match 'cycle_time_report/team', to: 'cycle_time_report#team', via: [:get, :post]
  match 'cycle_time_report/deployment_constraint', to: 'cycle_time_report#deployment_constraint', via: [:get, :post]
  get 'cycle_time_report/four_week_overview', to: 'cycle_time_report#four_week_overview'
  get 'cycle_time_report/two_week_overview', to: 'cycle_time_report#two_week_overview'
  get 'deployment_report/overview', to: 'deployment_report#overview'
  get 'p1_report/overview', to: 'p1_report#overview'
  get 'sprint_report/sprint', to: 'sprint_report#sprint'
  get 'department_report/cycle_time_overview', to: 'department_report#cycle_time_overview'
  get 'department_report/deployments_overview', to: 'department_report#deployments_overview'
  get 'department_report/issues_overview', to: 'department_report#issues_overview'
  get 'department_report/p1s_overview', to: 'department_report#p1s_overview'
  get 'department_report/kpi_overview', to: 'department_report#kpi_overview'
  post 'sprint_report/refresh_data', to: 'sprint_report#refresh_data'
end

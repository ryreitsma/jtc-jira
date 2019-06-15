Rails.application.routes.draw do
  root 'cycle_time_report#deployment_constraint'
  scope :jira do
    get '/', to: 'cycle_time_report#deployment_constraint'
    resources :teams, only: [:index]
    get 'sprint_report/last_sprint', to: 'sprint_report#last_sprint', as: :last_sprint_report
    get 'sprint_report/sprint', to: 'sprint_report#sprint', as: :sprint_report
    get 'report/portfolio', to: 'report#portfolio', as: :portfolio_report
    match 'cycle_time_report/team', to: 'cycle_time_report#team', as: :cycle_time_team, via: [:get, :post]
    match 'cycle_time_report/deployment_constraint', to: 'cycle_time_report#deployment_constraint', as: :cycle_time_deployment_constraint, via: [:get, :post]
    get 'report/deployment', to: 'report#deployment', as: :deployment_report
    get 'report/p1', to: 'report#p1', as: :p1_report
    post 'sprint_report/refresh_data', to: 'sprint_report#refresh_data', as: :sprint_report_refresh
  end

  resources :teams, only: [:index]
  get 'sprint_report/last_sprint', to: 'sprint_report#last_sprint'
  get 'report/portfolio', to: 'report#portfolio'
  match 'cycle_time_report/team', to: 'cycle_time_report#team', via: [:get, :post]
  match 'cycle_time_report/deployment_constraint', to: 'cycle_time_report#deployment_constraint', via: [:get, :post]
  get 'report/deployment', to: 'report#deployment'
  get 'report/p1', to: 'report#p1'
  get 'sprint_report/sprint', to: 'sprint_report#sprint'
  post 'sprint_report/refresh_data', to: 'sprint_report#refresh_data'
end

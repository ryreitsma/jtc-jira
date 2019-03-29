Rails.application.routes.draw do
  root 'report#cycle_time'
  scope :jira do
    get '/', to: 'report#cycle_time'
    resources :teams, only: [:index]
    get 'sprint_report/last_sprint', to: 'sprint_report#last_sprint', as: :last_sprint_report
    get 'sprint_report/sprint', to: 'sprint_report#sprint', as: :sprint_report
    get 'report/portfolio', to: 'report#portfolio', as: :portfolio_report
    match 'report/cycle_time', to: 'report#cycle_time', as: :cycle_time_report, via: [:get, :post]
    get 'report/deployment', to: 'report#deployment', as: :deployment_report
    get 'report/p1', to: 'report#p1', as: :p1_report
    post 'sprint_report/refresh_data', to: 'sprint_report#refresh_data', as: :sprint_report_refresh
  end

  resources :teams, only: [:index]
  get 'sprint_report/last_sprint', to: 'sprint_report#last_sprint'
  get 'report/portfolio', to: 'report#portfolio'
  match 'report/cycle_time', to: 'report#cycle_time', via: [:get, :post]
  get 'report/deployment', to: 'report#deployment'
  get 'report/deployment', to: 'report#p1'
  get 'sprint_report/sprint', to: 'sprint_report#sprint'
  post 'sprint_report/refresh_data', to: 'sprint_report#refresh_data'
end

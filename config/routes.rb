Rails.application.routes.draw do
  root 'teams#index'
  resources :teams
  get 'sprint_report/last_sprint', to: 'sprint_report#last_sprint', as: :last_sprint_report
  get 'sprint_report/sprint', to: 'sprint_report#sprint', as: :sprint_report
  post 'sprint_report/refresh_data', to: 'sprint_report#refresh_data', as: :sprint_report_refresh
end

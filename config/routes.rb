Rails.application.routes.draw do
  resources :rc_transfer_schedules do 
    collection do
      get :index
      put :index
    end
  end
  
  resources :rc_transfers, except: :index do
    collection do
      put  'update_multiple'
      get :index
      put :index
    end
    member do
      put :retry
    end
  end
  resources :rc_apps
  resources :rc_unapproved_records, controller: 'rc_transfer_unapproved_records'
  
  get 'rc_transfers/:id/audit_steps/:step_name' => 'rc_transfers#audit_steps'
  get '/rc_transfer_schedules/:id/audit_logs' => 'rc_transfer_schedules#audit_logs'
  put '/rc_transfer_schedules/:id/approve' => "rc_transfer_schedules#approve"
  get '/rc_apps/:id/audit_logs' => 'rc_apps#audit_logs'
  put '/rc_apps/:id/approve' => "rc_apps#approve"
  get '/rc_transfer_schedules/udfs/:rc_app_id' => 'rc_transfer_schedules#udfs'
end

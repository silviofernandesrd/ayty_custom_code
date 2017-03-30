##### AYTYCRM - Silvio Fernandes #####

# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

resources :ayty_dashboards do
  collection do
    post :add_block
    put :sort
  end
  member do
    post :add
  end
end

resources :ayty_access_levels

resources :ayty_roles

resources :ayty_managed_roles

resources :ayty_time_entry_types

post '/principal_memberships/ayty_replicate_memberships/ayty', :to => 'principal_memberships#ayty_replicate_memberships'
post '/users/ayty_replicate_memberships/ayty', :to => 'users#ayty_replicate_memberships'

get '/users/index_manager/ayty', :to => 'users#index_manager'
get '/users/index_managed/ayty', :to => 'users#index_managed'
get '/users/edit_manager/ayty', :to => 'users#edit_manager'
get '/users/edit_managed/ayty', :to => 'users#edit_managed'
post '/users/update_manager', :to => 'users#update_manager'
post '/users/update_managed', :to => 'users#update_managed'
delete '/users/delete_all_manager/:id', :to => 'users#delete_all_manager'
delete '/users/delete_all_managed/:id', :to => 'users#delete_all_managed'

get '/issues/ayty_template_notes/ayty', :to => 'issues#ayty_template_notes'

get '/journals/toggle_journal_ayty_hidden', :to => 'journals#toggle_journal_ayty_hidden'

get '/journals/toggle_journal_ayty_marked', :to => 'journals#toggle_journal_ayty_marked'

resources :ayty_issue_priorities do
  collection do
    post 'ayty_update_priorities'
    get 'ayty_render_responsible'
    get 'ayty_render_time_tracker_pendings'
    get 'ayty_render_watcher'
    get 'ayty_render_play'
  end

end

get '/time_trackers/add_status_transition', :to => 'time_trackers#add_status_transition'
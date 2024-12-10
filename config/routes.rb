Rails.application.routes.draw do
  # Routes for the Email resource:
  root to: "emails#index"
  # CREATE
  post("/insert_email", { :controller => "emails", :action => "create" })
          
  # READ
  get("/emails", { :controller => "emails", :action => "index" })
  
  get("/emails/:path_id", { :controller => "emails", :action => "show" })
  
  # UPDATE
  
  post("/modify_email/:path_id", { :controller => "emails", :action => "update" })
  
  # DELETE
  get("/delete_email/:path_id", { :controller => "emails", :action => "destroy" })

  #------------------------------

  devise_for :users

  # This is a blank app! Pick your first screen, build out the RCAV, and go from there. E.g.:

  # get "/your_first_screen" => "pages#first"
  
end

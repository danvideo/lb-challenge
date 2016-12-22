# start the app by running
# `ruby sw-4567.rb`
# 
# for more app servers, clone this file and increment filenames and ports 
# sw-4568, 4569, etc...
# 
# run in different terminal windows or as background processes
# 
# dependencies to match testing env are ruby + sinatra and puma gems

require "sinatra"

set :port, 4567
set :server, 'puma'

get "/" do
  200
end

get "/login" do
  "OK - you have made a GET request successfully"
end

post "/register" do
  "OK - you have made a POST request successfully"
end

post "/changePassword" do
  "OK - you have made a POST request successfully"
end


# start the app by running
# `ruby sw-server.rb 4568`
# 
# for more app servers, rerun this file and increment ports 
# `ruby sw-server 4568`, `ruby sw-server 4569`, etc...
# 
# run in different terminal windows or as background processes
# 
# dependencies to match testing env are ruby + sinatra and puma gems

require "sinatra"

port = (ARGV[0] || 4567).to_i
set :port, port
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


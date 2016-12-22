# Commands for deployment and testing
# 
# Can run these as background processes but easier in term windows to see traffic :)
#
# -------
# DEPLOY
# -------
# So you've setup and deployed HAProxy, it's listening on :80
# sending POSTs to :9000, GETs to :4567, :4568, :4569
#
# terminal window #1
./teeproxy -l :9000 -a 127.0.0.1:4567 -b 127.0.0.1:9001

# window #2
./teeproxy -l :9001 -a 127.0.0.1:4568 -b 127.0.0.1:4569
# here teeproxy sends to both remaining app servers, with more windows 
# it could easily keep forwarding around the POSTs to N more :9002, :9003, etc

#window #3 
ruby w-4567.rb 
#4 
ruby sw-4568.rb
#5 
ruby sw-4569.rb

# -------
# TESTING
# -------
# Apache Bench
# here pointing to localhost (webserver) but better if run from remote (laptop)

ab -n 5000 -c 1000 http://127.0.0.1:80/login

touch postfile # for POST requests
ab -p postfile -n 1000 -c 50 http://127.0.0.1:80/changePassword

ab -p postfile -n 1000 -c 50 http://127.0.0.1:80/register
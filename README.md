# Take Home Challenge (SW)

### Goal is to create a load balancer solution to handle N<10 app servers
* POST urls '/register' and '/changePassword' go to all N webservers at the same time (100 req/sec)
* GET url '/login' goes to 1 webserver at a time, roundrobin (1000 req/sec)
* Expose metrics for easy monitoring
* Should be able to hit request rate on an average size server

### Solution is in three parts:
* HAProxy to divide incoming GET and POSTs, also to load balance GET requests (and honors case as well)
* teeproxy to forward POST requests (small Golang app)
* The forwarding is setup in linked-list style (A sends to B, B to C, etc, i.e. not A blasting to all 10 nodes)

###Reasoning: 
* writing something custom would probably take too long
* using already existing tools would provide better metrics
* use a scalable algorithm for the POST forwarding

####Detailed Rundown and Traffic Flow:
For testing this, I setup the following on small CentOS box: <br>
* **1 HAProxy instance** (listening on :80) <br>
* **3 Ruby (Sinatra) app servers** to respond to the POST and GET urls (:4567-9) (And note - this could be any lightweight app server, node.js, etc) <br>
* **2 teeproxy instances**, HTTP forwarder (:9000 & :9001) [teeproxy on github](https://github.com/chrislusf/teeproxy) <br>
* In short, all of the N app servers are on various localhost posts, along with the N forwarders and 1 load balancer.

1. Incoming "Internet" traffic
	* Apache Bench used for testing and generating traffic
	* 1000 GET & 100 POST requests/second sent to CentOS 7 server port 80
	* HAProxy listening (config included)

2. HAProxy LB
	* Divides traffic by GET vs. POST
	* sends GET roundrobin to N servers (in this case 3 localhost apps: ports :4567, 4568, 4569)
	* sends POST requests to the 1st of N servers (localhost:9000)

3. teeproxy on "webserver" #1 (:9000 listening) forwards the POST request to two places:
	* the 1st app server (localhost:4567) which returns a response
	* the teeproxy instance on next (#2) webserver (listening on port 9001)

4. teeproxy on #2 (:9001 listening) forwards POST request to two places:
	* the app on that server (localhost:4568), no response
	* sends to teeproxy instance on server #3 (port 9002)

5. And so on for N servers.

#### How to Deploy / Test

* For the purposes of this assignment I installed and deployed it on one CentOS server with the following: Ruby, Sinatra, Go, HAProxy, Apache Bench, and teeproxy.
* The following files are included:
	* `README.md` this document
	* `sw-server.rb.rb` Ruby file for example of basic app server setup
	* `haproxy.cfg` HAProxy config file
	* `misc-commands.sh` Apache Bench & teeproxy commands
* Note [teeproxy GO app](https://github.com/chrislusf/teeproxy) needs to be built with a small code change in lines 72 and 105.  Change this: <br>
`if err != nil { ` <br>
To this: <br>
 `if err != nil && err != httputil.ErrPersistEOF {`

#### Metrics
* load balancer data available on port :1936, generated by HAProxy (see username/pass)
* Testing w/ Apache Bench yielded: <br> ~500+ GETs/second and 200+ POSTs on a VERY underpowered localhost (1 CPU, 1 GB RAM) to prove concept.
* I'm confident on a larger box or cluster we'd be in good shape.  Also haproxy could probably use some tweaking as well.

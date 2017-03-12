require 'google_maps_service'

# Setup API keys
apiKey = ENV["GOOGLE_MAP_KEY"]
gmaps = GoogleMapsService::Client.new(key: apiKey)

if (ARGV.length != 1) then
  print "Usage: ruby addressToLatLng.rb ADDRESS_LIST_file\n"
  exit
end

addressList = File.open(ARGV[0], "r").readlines()

addressList.each do |address|
  address.chomp!
  print "try geocode address=#{address}\n"
  results = gmaps.geocode(address)
  print "results=#{results}\n"
end

x = """
 ruby addressToLatLng.rb ../data/TEST_ADDRESS.txt
/Users/jojo/.rvm/rubies/ruby-2.2.1/lib/ruby/2.2.0/net/http.rb:923:in `connect': SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed (Hurley::SSLError)
	from /Users/jojo/.rvm/rubies/ruby-2.2.1/lib/ruby/2.2.0/net/http.rb:923:in `block in connect'
	from /Users/jojo/.rvm/rubies/ruby-2.2.1/lib/ruby/2.2.0/timeout.rb:74:in `timeout'
	from /Users/jojo/.rvm/rubies/ruby-2.2.1/lib/ruby/2.2.0/net/http.rb:923:in `connect'
	from /Users/jojo/.rvm/rubies/ruby-2.2.1/lib/ruby/2.2.0/net/http.rb:863:in `do_start'
	from /Users/jojo/.rvm/rubies/ruby-2.2.1/lib/ruby/2.2.0/net/http.rb:852:in `start'
	from /Users/jojo/.rvm/rubies/ruby-2.2.1/lib/ruby/2.2.0/net/http.rb:1375:in `request'
	from /Users/jojo/.rvm/rubies/ruby-2.2.1/lib/ruby/2.2.0/net/http.rb:1133:in `get'
	from /Users/jojo/.rvm/gems/ruby-2.2.1/gems/hurley-0.2/lib/hurley/connection.rb:80:in `perform_request'
	from /Users/jojo/.rvm/gems/ruby-2.2.1/gems/hurley-0.2/lib/hurley/connection.rb:15:in `block (2 levels) in call'

"""
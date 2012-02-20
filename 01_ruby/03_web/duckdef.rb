require 'open-uri'
require 'json'

query = ARGV.shift                                                  # query string
unless query
  puts "ERROR: a query needs to be specified"
  exit
end

BASE_URL = "http://api.duckduckgo.com/?format=json&pretty=1&q="     # remote API url
query_url = BASE_URL + URI.escape(query)                            # putting the 2 together


object = open(query_url) do |v|                                     # call the remote API
  input = v.read                                                    # read the full response
#  puts input                                                       # un-comment this to see the returned JSON magic
  JSON.parse(input)                                                 # parse the JSON & return it from the block
end

puts " ======================================== "                   # fancy output
puts "   #{object["Definition"]}"                                   # only print the definition
puts " ======================================== "

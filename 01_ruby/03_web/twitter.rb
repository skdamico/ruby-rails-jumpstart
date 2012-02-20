require 'open-uri'
require 'json'

query = ARGV.shift                                                  # query string
unless query
  puts "ERROR: a query needs to be specified"
  exit
end

# create a search to Twitter returned 5 popular and recent results
BASE_URL = "http://search.twitter.com/search.json?result_type=mixed&rpp=5&q="
query_url = BASE_URL + URI.escape(query)                            # putting the 2 together


object = open(query_url) do |v|                                     # call the remote API
  input = v.read                                                    # read the full response
#  puts input                                                       # un-comment this to see the returned JSON magic
  JSON.parse(input)                                                 # parse the JSON & return it from the block
end

puts " ======================================== "                   # fancy output
puts "   Twitter results for '#{query}'"
puts "   Completed in #{object['completed_in']} secs"               # how fast did it complete?

puts " ======================================== "                   # fancy output
puts "   Results"
puts " ---------------------------------------- "

object['results'].each do |r|                                       # processing sub-elements
  puts
  puts "  +  #{r['from_user']} said:"                               # <User> said:
  puts "        #{r['text']}"                                       #    blah blah blah
end

puts                                                                # fancy output
puts " ---------------------------------------- "
puts " ======================================== "

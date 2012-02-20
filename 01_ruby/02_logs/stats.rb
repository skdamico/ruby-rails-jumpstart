
filename = ARGV.shift                         # get a filename from the command line arguments

unless filename                               # we can't work without a filename
  puts "no filename specified!"
  exit
end

lines = 0                                     # a humble line counter

                                              # default hashes at 0 for easy '+=' operation
all_days = Hash.new(0)
all_users = Hash.new(0)
all_pages = Hash.new(0)

page_views = {}                               # empty hash for pages to users viewing them

open(filename).each do |m|                    # loop over every line of the file
  m.chomp!                                    # remove the trailing newline

  unless m.match(/DATE,USER_ID,URL/)          # ignore the header line
    values = m.split(",")                     # split comma-separated fields into a values array

    day, user, page = values                  # assign values to good names

    all_days[day] += 1                        # get day
    all_users[user] += 1                      # get user
    all_pages[page] += 1                      # get page

    unless page_views.has_key?(page)          # initialize empty page/user array
      page_views[page] = []
    end

    unless page_views[page].include?(user)    # only add user to list if not added already
      page_views[page] << user                # add users to page
    end

    lines += 1                                # bump the counter
  end
end

                                              # do calculations based on gathered data
unique_users = all_users.length               # returns all keys for users
unique_pages = all_pages.length               # returns all keys for pages

                                              # sort the Hash into a value sorted Array
                                              # get the last key in the 2D array
most_active_day = all_days.sort_by {|k,v| v}.last[0]
most_active_user = all_users.sort_by {|k,v| v}.last[0]
most_active_page = all_pages.sort_by {|k,v| v}.last[0]

popular_page = ""
popular_page_user_count = 0

page_views.each do |page,users|               # find most unique users in each page/user map
  count = users.count
  if count > popular_page_user_count          # test if this unique user count is higher
    popular_page = page                       # make this the new popular page
    popular_page_user_count = count
  end
end


puts "total lines: #{lines}"                  # output stats
puts "unique users: #{unique_users}"
puts "unique pages: #{unique_pages}"
puts "most active day: #{most_active_day}"
puts "most active user: #{most_active_user}"
puts "most active page: #{most_active_page}"
puts "most popular page: #{popular_page}"

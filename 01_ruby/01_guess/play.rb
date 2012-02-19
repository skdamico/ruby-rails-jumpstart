require 'open3'

# default to playing with a limit of 10
limit = (ARGV.shift || "10").to_i


# open a child process for the game using the Open3 library
status =
  Open3.popen3("ruby guess.rb #{limit}") do |child_stdin, child_stdout, child_stderr, wait_thr|
    puts ">>> pid        : #{ wait_thr.pid }"       # report the child pid for informational purposes

    # implemented a sort of binary search algorithm
    finished = false                                # we're just getting started!

    low = 1                                         # low boundary always starts at 1
    high = limit                                    # high boundary always starts at limit

    until finished                                  # keep looping until we're done
      guess = low + ((high - low) / 2).to_i         # find the mid point between both boundaries

      inline = child_stdout.readline.strip          # get input from the game process

      unless inline.match(/GUESS/)                  # make sure the game is asking what we expect
        puts "Unexpected input! #{inline}"
        exit                                        # if not ... exit
      end

      puts "< " + inline                            # report the input from game
      puts "> " + guess.to_s                        # report the guess we're about to make
      child_stdin.puts guess                        # send the guess to the game process
      response = child_stdout.readline.strip        # get the result from the game process
      puts "< " + response                          # report the result

      if response.match(/:exiting/)
        finished = true                             # if the response includes ':exiting', we're done
      elsif response.match(/:too low/) and guess < high
        low = guess + 1                             # guess is less than high boundary and still too low
      elsif response.match(/:too high/) and guess > low
        high = guess - 1                            # guess is greater than low boundary and still too high
      else
        puts ">>> exitstatus : computer is lying!"  # computer is lying. guess is equal to low or high boundary and not correct
        exit
      end
    end

    puts ">>> exitstatus : #{ wait_thr.value }"
  end


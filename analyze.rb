require "rubygems"
require "bundler/setup"

require 'fastercsv'

# Initialize some stuff
uservisits = {}
realvisits = {}

# Parse the CSV, put all the events on a Hash where
# The key is the user id
FasterCSV.foreach('events.csv', :col_sep => "\t") do |row|
  visitarray = uservisits[row[2].to_i] || []
  visitarray << row[3].to_i
  uservisits[row[2].to_i] = visitarray
end

# Now parse that Hash and analyze each array of events to determine
# unique visits and their duration
uservisits.each do |k, v|
  firstvisit = lastvisit = nil
  uservisits[k].sort.each do |visit|
    firstvisit ||= visit
    lastvisit ||= visit

    # If there's a difference of more than a n hour...
    if visit - lastvisit > 3600
      realvisits[k] ||= []
      realvisits[k] << visit - firstvisit
      lastvisit = firstvisit = nil
    else # If not...
      lastvisit = visit
    end
  end

  # For the last visit, even if the data is incomplete, or
  # if it's not for more than 1 hourit counts as a visit
  realvisits[k] ||= []
  realvisits[k] << uservisits[k].sort.last - firstvisit
end

# Now parse the results and do some formatting
realvisits.each do |k, v|
  puts %{User #{k}, had #{v.size} visits: #{v.join("s ")}s}
end
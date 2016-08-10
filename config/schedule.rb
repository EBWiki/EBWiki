# Use this file to easily define all of your cron jobs.

# refresh sitemap
every 1.day, :at => '5:00 am' do
	if Rails.env.production?
	  rake "-s sitemap:refresh"
	end
end

# preserve storage capacity by deleting oldest snapshot
every 1.day, :at => '5:15 am' do
  if Rails.env.production?
    rake "autobus_cleanup"
  end
end

#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever


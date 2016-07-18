if Rails.const_defined? 'Console'
  STDOUT.print "Enter your name for PaperTrail.whodunnit : "
  username = STDIN.gets.split("\n").first
  puts "Hello #{username}!"
  PaperTrail.whodunnit = username
end
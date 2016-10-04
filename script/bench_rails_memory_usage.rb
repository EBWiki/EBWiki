require "net/http"

def start_server
  # Remove the X to enable the parameters for tuning.
  # These are the default values as of Ruby 2.2.0.
  @child = spawn(<<-EOC.split.join(" "))
    RUBY_GC_HEAP_FREE_SLOTS=4096
    RUBY_GC_HEAP_INIT_SLOTS=10000
    RUBY_GC_HEAP_GROWTH_FACTOR=1.8
    RUBY_GC_HEAP_GROWTH_MAX_SLOTS=0
    RUBY_GC_HEAP_OLDOBJECT_LIMIT_FACTOR=2.0
    RUBY_GC_MALLOC_LIMIT=16777216
    RUBY_GC_MALLOC_LIMIT_MAX=33554432
    RUBY_GC_MALLOC_LIMIT_GROWTH_FACTOR=1.4
    RUBY_GC_OLDMALLOC_LIMIT=16777216
    RUBY_GC_OLDMALLOC_LIMIT_MAX=134217728
    RUBY_GC_OLDMALLOC_LIMIT_GROWTH_FACTOR=1.2
    rails server -p3009 > /dev/null
  EOC
  sleep 0.1 until alive?
end

def alive?
  system("curl http://localhost:3009/ &> /dev/null")
end

def stop_server
  Process.kill "HUP", server_pid
  Process.wait @child
end

def server_pid
  `cat tmp/pids/server.pid`.to_i
end

def memory_size_mb
  (`ps -o rss= -p #{server_pid}`.to_i * 1024).to_f / 2**20
end

# In /etc/hosts I have api.rails.local set to 127.0.0.1 for
# API testing on any app. Curl freaks out and takes extra
# seconds to do the request to these .local things, so we
# will use Net::HTTP for moar speed.
def do_request
  uri = URI("http://localhost:3009/articles")
  req = Net::HTTP::Get.new(uri)
  # Remove the next line if you don't need HTTP basic authentication.
  req["Content-Type"] = "application/json"

  Net::HTTP.start("localhost", uri.port) do |http|
    http.read_timeout = 60
    http.request(req)
  end
end

results = []

# You can’t just measure once: memory usage has some variance.
# We will take the mean of 7 runs.
7.times do
  start_server

  used_mb = nil
  (1..30).map do |n|
    print "Request #{n}..."
    do_request
    used_mb = memory_size_mb
    puts "#{used_mb} MB"
  end

  final_mb = used_mb
  results << final_mb
  puts "Final Memory: #{final_mb} MB"

  stop_server
end

mean_final_mb = results.reduce(:+) / results.size
puts "Mean Final Memory: #{mean_final_mb} MB"
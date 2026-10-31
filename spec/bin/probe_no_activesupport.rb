# frozen_string_literal: true

at_exit do
  puts "ACTIVESUPPORT=#{defined?(ActiveSupport).inspect}"
end

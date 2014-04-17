#!/usr/bin/env ruby

require 'open3'

stdout_str, stderr_str, status = Open3.capture3('brew info youtube-dl')
puts "stdout: #{stdout_str}"
puts "stderr: #{stderr_str}"
p status

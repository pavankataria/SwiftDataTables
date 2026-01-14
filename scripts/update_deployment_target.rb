#!/usr/bin/env ruby
# Script to update iOS deployment target for all targets
# Usage: ruby scripts/update_deployment_target.rb

require 'xcodeproj'

project_path = File.expand_path('../Example/SwiftDataTables.xcodeproj', __dir__)
project = Xcodeproj::Project.open(project_path)

NEW_TARGET = '12.0'

# Update project-level build settings
project.build_configurations.each do |config|
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = NEW_TARGET
  puts "Updated project config '#{config.name}' to iOS #{NEW_TARGET}"
end

# Update each target's build settings
project.targets.each do |target|
  target.build_configurations.each do |config|
    config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = NEW_TARGET
  end
  puts "Updated target '#{target.name}' to iOS #{NEW_TARGET}"
end

project.save
puts "Done! Project saved with iOS deployment target #{NEW_TARGET}"

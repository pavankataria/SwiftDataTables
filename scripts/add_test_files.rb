#!/usr/bin/env ruby
# Script to add new test files to the SwiftDataTablesTests target
# Usage: ruby scripts/add_test_files.rb

require 'xcodeproj'

project_path = File.expand_path('../Example/SwiftDataTables.xcodeproj', __dir__)
project = Xcodeproj::Project.open(project_path)

# Find the SwiftDataTablesTests target
test_target = project.targets.find { |t| t.name == 'SwiftDataTablesTests' }

unless test_target
  puts "Error: Could not find SwiftDataTablesTests target"
  exit 1
end

# Find the SwiftDataTablesTests group
test_group = project.main_group.find_subpath('SwiftDataTablesTests', false)

unless test_group
  puts "Error: Could not find SwiftDataTablesTests group"
  exit 1
end

# New test files to add
new_test_files = [
  'DataTableValueTypeTests.swift',
  'DataTableSortTypeTests.swift',
  'DataTableConfigurationTests.swift',
  'DataTableFixedColumnTypeTests.swift',
  'DataHeaderFooterViewModelTests.swift'
]

# Get existing file references in the group
existing_files = test_group.files.map(&:display_name)

# Add each new file
new_test_files.each do |filename|
  if existing_files.include?(filename)
    puts "Skipping #{filename} - already in project"
    next
  end

  file_path = File.expand_path("../Example/SwiftDataTablesTests/#{filename}", __dir__)

  unless File.exist?(file_path)
    puts "Warning: #{filename} does not exist at #{file_path}"
    next
  end

  # Add file reference to group
  file_ref = test_group.new_file(file_path)

  # Add to target's compile sources
  test_target.source_build_phase.add_file_reference(file_ref)

  puts "Added #{filename} to SwiftDataTablesTests target"
end

# Save the project
project.save

puts "Done! Project saved."

require 'xcodeproj'

project_path = 'UltimateNotch/boringNotch.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Find the Tabs group
tabs_group = project.main_group.find_subpath(File.join('boringNotch', 'components', 'Tabs'), true)

# Create VibeIsland group
vibe_group = tabs_group.find_subpath('VibeIsland', true)
vibe_group.set_source_tree('<group>')
vibe_group.set_path('VibeIsland')

# Add files
models_ref = vibe_group.new_file('VibeModels.swift')
server_ref = vibe_group.new_file('VibeSocketServer.swift')

# Add to target
target.add_file_references([models_ref, server_ref])

project.save
puts "Files added to project."

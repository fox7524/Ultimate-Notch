require 'xcodeproj'

project_path = 'UltimateNotch/boringNotch.xcodeproj'
project = Xcodeproj::Project.open(project_path)

project.files.each do |file|
  if file.path == 'VibeIslandPlaceholderView.swift' || file.path.end_with?('VibeIslandPlaceholderView.swift')
    file.path = file.path.sub('VibeIslandPlaceholderView.swift', 'VibeIslandView.swift')
    file.name = 'VibeIslandView.swift'
    puts "Renamed reference to #{file.path}"
  end
end

project.save

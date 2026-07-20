require 'xcodeproj'

project_path = 'UltimateNotch/boringNotch.xcodeproj'
project = Xcodeproj::Project.open(project_path)

target = project.targets.find { |t| t.name == 'boringNotch' }
main_group = project.main_group.find_subpath('boringNotch', true)

['enter.mp3', 'eshop.mp3'].each do |file_name|
  file_ref = main_group.new_reference(file_name)
  target.resources_build_phase.add_file_reference(file_ref)
end

project.save
puts "Added enter.mp3 and eshop.mp3 to boringNotch target resources."
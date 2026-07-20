require 'xcodeproj'

project_path = 'UltimateNotch/boringNotch.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

def add_files_to_group(project, target, group_path, physical_path)
  # Create group if it doesn't exist
  components_group = project.main_group.find_subpath('boringNotch/components', true)
  group = components_group.find_subpath('Clicky', true)
  group.set_source_tree('SOURCE_ROOT')
  
  Dir.glob(physical_path + '/*.swift').each do |file|
    filename = File.basename(file)
    unless group.files.any? { |f| f.path == filename || f.name == filename }
      file_ref = group.new_reference(file)
      target.add_file_references([file_ref])
      puts "Added #{filename}"
    end
  end
end

add_files_to_group(project, target, 'boringNotch/components/Clicky', 'UltimateNotch/boringNotch/components/Clicky')

project.save
puts "Saved."

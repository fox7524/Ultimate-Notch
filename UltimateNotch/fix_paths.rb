require 'xcodeproj'

project_path = 'boringNotch.xcodeproj'
project = Xcodeproj::Project.open(project_path)

project.files.each do |file|
  path = file.path
  next if path.nil?
  
  if path.include?('UltimateNotch/boringNotch/components/Clicky')
    new_path = path.sub(/.*UltimateNotch\/boringNotch\/components\/Clicky/, 'boringNotch/components/Clicky')
    file.path = new_path
    file.source_tree = '<group>'
    puts "Fixed #{path} to #{new_path}"
  elsif path.include?('UltimateNotch/boringNotch/components/Tabs')
    new_path = path.sub(/.*UltimateNotch\/boringNotch\/components\/Tabs/, 'boringNotch/components/Tabs')
    file.path = new_path
    file.source_tree = '<group>'
    puts "Fixed #{path} to #{new_path}"
  elsif path.include?('Tabs/') && !path.include?('boringNotch/components/Tabs/')
    new_path = path.sub(/.*Tabs\//, 'boringNotch/components/Tabs/')
    file.path = new_path
    file.source_tree = '<group>'
    puts "Fixed #{path} to #{new_path}"
  end
end

project.save
puts "Project saved"

require 'xcodeproj'

project_path = 'boringNotch.xcodeproj'
project = Xcodeproj::Project.open(project_path)

project.groups.each do |group|
  # We want to find the Tabs group and the Clicky group
  # and set their path properly.
  
  def fix_group(g)
    if g.name == 'Tabs' || g.path == 'Tabs'
      puts "Found Tabs group! current path: #{g.path}, source_tree: #{g.source_tree}"
      g.path = 'boringNotch/components/Tabs'
      g.source_tree = 'SOURCE_ROOT'
      
      # fix its children
      g.children.each do |child|
        if child.path
          child.path = child.path.split('/').last
          child.source_tree = '<group>'
        end
      end
    end
    
    if g.name == 'Clicky' || g.path == 'Clicky' || g.path == 'UltimateNotch'
      puts "Found Clicky group! current path: #{g.path}, source_tree: #{g.source_tree}"
      g.path = 'boringNotch/components/Clicky'
      g.source_tree = 'SOURCE_ROOT'
      
      # fix its children
      g.children.each do |child|
        if child.path
          child.path = child.path.split('/').last
          child.source_tree = '<group>'
        end
      end
    end
    
    g.groups.each do |subgroup|
      fix_group(subgroup)
    end
  end
  
  fix_group(group)
end

project.save
puts "Project saved"

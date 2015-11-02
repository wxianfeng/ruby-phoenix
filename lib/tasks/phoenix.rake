require "rake"

namespace :phoenix do

  desc "Install ruby-phoenix jar package"
  task :install do
    $stdout.print "pls input password to copy jar to /Library/Java/Extensions/\n"

    path = File.expand_path("../../../resources/",__FILE__)
    system("sudo cp #{path}/* /Library/Java/Extensions/")

    if !File.exists? "#{Rails.root}/config/phoenix.yml"
      file = File.open("#{Rails.root}/config/phoenix.yml", "w")
      file.write("host: your hbase host\nport: your hbase port\n")
      file.close
    end
    
  end

end
require "bundler/gem_tasks"

desc "Sync Files To Gitub Project"
task :sync do
  system "rsync -vzrtopg --progress --exclude-from=rules.txt /data/projects/alibaba/ruby-phoenix/*  /data/projects/ruby-phoenix/"
end
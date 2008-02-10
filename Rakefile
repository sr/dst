require 'rubygems'
require 'rake'
require 'spec/rake/spectask'

Version = '0.0.1'

begin
  require 'echoe'

  Echoe.new('dst', Version) do |p|
    p.summary = 'a KISS GTD manager for the command line lovers.'
    p.description = 'a KISS GTD manager for the command line lovers.'
    p.url = 'http://atonie.org/2008/dst'
    p.author = 'Simon Rozet'
    p.email = 'simon@rozet.name'
    p.dependencies  << 'activerecord >=2.0.2'
    p.clean_pattern << 'report.html'
    p.clean_pattern << 'coverage'
  end
rescue LoadError => boom
  puts 'You are missing a dependency required for meta-operations on this gem.'
  puts boom.to_s.capitalize
end

desc 'Install the package as a gem, without generating documentation'
task :install_gem_no_doc => [:clean, :package] do
  sh "#{'sudo ' unless Hoe::WINDOZE }gem install pkg/*.gem --no-rdoc --no-ri"
end

task :default => 'spec'
desc 'Run specs'
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--format', 'specdoc', '--colour', '--diff']
end

desc 'Generate coverage reports'
Spec::Rake::SpecTask.new('spec:coverage') do |t|
  t.rcov = true
end

desc 'Generate a nice HTML report of spec results'
Spec::Rake::SpecTask.new('spec:report') do |t|
  t.spec_opts = ['--format', 'html:report.html', '--diff']
end

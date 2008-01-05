require 'rake'
require 'spec/rake/spectask'

task :default => 'spec'

desc 'Run all specs and generate report for spec results and code coverage'
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_opts = ["--format", "html:report.html", '--diff'] 
  t.fail_on_error = false
  t.rcov = true
end


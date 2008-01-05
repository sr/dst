require 'rubygems'
require 'dst/models'

class Dst
  include Models
  
  def self.process_command(command)
    new.process_command(command)
  end

  def process_command(command)
    options = extract_options_from_command(command)
    if command.blank? || !options.has_key?(:description)
      list_tasks(options)
    elsif command =~ /^\^(\d+)$/
      toggle_task($1.to_i)
    else
      create_task(options)
    end
  end

  def create_task(options={})
    task = Task.new(:description => options[:description])
    task.context = Context.find_or_create_by_name(options[:context]) if options.has_key?(:context)
    task.project = Project.find_or_create_by_name(options[:project]) if options.has_key?(:project)
    task.save
    puts "#{task} have been successfuly created"
  end

  def toggle_task(task_id)
    task = Task.toggle!(task_id)
    puts "Ok, task marked as `#{task.status}'"    
  rescue ActiveRecord::RecordNotFound
    puts "Oops, task ##{task_id} not found"
  end

  def list_tasks(options={}, include_completed=false)
    context, project = options.values_at(:context, :project)
    tasks = if options.empty?
              Task.unfinished
            elsif context
              Task.unfinished(:include => [:context, :project]).find_all { |task|
                task.context.name == context if task.context
              }
            elsif project
              Task.unfinished(:include => [:context, :project]).find_all { |task|
                task.project.name == project if task.project
              }
            end || []
    puts tasks.empty? ? 'No tasks found' : tasks.map(&:to_s).join("\n")
  end

  protected
    def extract_options_from_command(command)
      context = command =~ /^@(\w+)/ && $1
      project = command =~ /(?!\w):(\w+)/ && $1
      description = command.dup
      description.gsub!("@#{context}", '') unless context.nil?
      description.gsub!(":#{project}", '') unless project.nil?
      options = {:context => context, :project => project, :description => description.strip}
      options.reject { |k, v| v.nil? || v.blank? }
    end
end

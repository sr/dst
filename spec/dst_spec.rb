$:.unshift 'lib/', File.dirname(__FILE__) + '/../lib'
require 'dst'

describe Dst do
  before(:each) do
    @dst = Dst.new
    @task_model = Dst::Models::Task
    @context_model = Dst::Models::Context
    @project_model = Dst::Models::Project

    @task = mock('Task', :context= => true, :project= => true, :save => true)
    @task_model.stub!(:new).and_return(@task)
  end

  it 'should exists' do
    @dst.should_not be_nil
    @dst.should be_an_instance_of(Dst)
  end

  describe "when creating tasks: `<@context> <:project> task'" do
    before(:each) do
      @command = '@mail :proj john@doe.name about http://example.org'
    end

    describe '#process_command' do
      it 'dispatchs command to create_task' do
        @dst.should_receive(:create_task)
        @dst.process_command(@command)
      end

      it 'parses description correctly' do
        @dst.should_receive(:create_task) do |opts|
          opts[:description].should == 'john@doe.name about http://example.org' 
        end
        @dst.process_command(@command)
      end

      it 'parses context correctly' do
        @dst.should_receive(:create_task) { |opts| opts[:context].should ==  'mail' } 
        @dst.process_command(@command)
      end

      it 'parses project correctly' do
        @dst.should_receive(:create_task) { |opts| opts[:project].should == 'proj' }
        @dst.process_command(@command)
      end
    end

    describe '#create_task' do
      before(:each) do
        @context = mock('Context')
        @context_model.stub!(:find_or_create_by_name).and_return(@context)

        @project = mock('Project')
        @project_model.stub!(:find_or_create_by_name).and_return(@project)
      end

      it 'creates a new Task with given description' do
        @task_model.should_receive(:new).with(
          :description  => 'john@doe.name about http://example.org'
        ).and_return(@task) 
        @dst.process_command(@command)
      end
  
      it 'finds or creates context' do
        @context_model.should_receive(:find_or_create_by_name).and_return(@context)
        @dst.process_command(@command)
      end

      it "sets task's context if specified" do
        @task.should_receive(:context=).with(@context)
        @dst.process_command(@command)
      end

      it "doesn't set tasks's context if not specified" do
        @task.should_not_receive(:context=)
        @dst.process_command('task without context')
      end

      it "finds or creates project" do
        @project_model.should_receive(:find_or_create_by_name).and_return(@project)
        @dst.process_command(@command)
      end

      it "sets task's project if specified" do
        @task.should_receive(:project=).with(@project)
        @dst.process_command(@command)
      end

      it "doesn't set tasks's project if not specified" do
        @task.should_not_receive(:project=)
        @dst.process_command('task without project')
      end

      it 'saves new task' do
        @task.should_receive(:save).and_return(true)
        @dst.process_command(@command)
      end

      it 'notices that tasks have been successfuly created' do
        @dst.should_receive(:puts).with(/ created.$/)
        @dst.process_command(@command)
      end
    end
  end

  describe "when toggling a task: `^<task id>'" do
    before(:each) do
      @task.stub!(:status).and_return(true)
      @task_model.stub!(:toggle!).and_return(@task)
    end

    describe '#proccess_command' do
      it 'dispatchs to toggle_task' do
        @dst.should_receive(:toggle_task).with(479)
        @dst.process_command('^479')
      end

      it 'parses task id correctly' do
        [1, 479, 0, 1087].each do |id|
          @dst.should_receive(:toggle_task).with(id)
          @dst.process_command("^#{id}")
        end
      end
    end

    describe '#toggle_task' do
      it 'toggle task' do
        @task_model.should_receive(:toggle!).with(3).and_return(@task)
        @dst.process_command('^3')
      end

      it 'outputs an error message if task not found' do
        @task_model.should_receive(:toggle!).and_raise(ActiveRecord::RecordNotFound)
        @dst.should_receive(:puts).with("Oops, task #98 not found.")
        @dst.process_command('^98')
      end
    end
  end

  describe "when listing tasks: `[<@context> <@project>] [-a]]'" do
    before(:each) do
      @tasks = mock('tasks', :find_all => [@task], :empty? => false, :map => [@task])
      @task_model.stub!(:unfinished).and_return(@tasks)
    end

    it 'finds all unfinished tasks if no filter provided' do
      @task_model.should_receive(:unfinished).and_return(@tasks)
      @tasks.should_not_receive(:find_all)
      @dst.process_command('')
    end

    it 'finds unfinished tasks filtered by context' do
      @task_model.should_receive(:unfinished).and_return(@tasks)
      @tasks.should_receive(:find_all)
      @dst.process_command('@context')
    end

    it 'finds unfinished tasks filtered by project' do
      @task_model.should_receive(:unfinished).and_return(@tasks)
      @tasks.should_receive(:find_all)
      @dst.process_command(':project')
    end
    
   it 'outputs tasks' do
      @tasks.should_receive(:map).and_return(@tasks)
      @tasks.should_receive(:join).and_return("")
      @dst.process_command('')
    end

    it 'notices if no tasks found' do
      @tasks.should_receive(:empty?).and_return(true)
      @dst.should_receive(:puts).with('No tasks found')
      @dst.process_command('')
    end
  end
end

require 'rubygems'
require 'active_record'

class Dst
  module Models
    class << self
      def schema(&block)
        @@schema = block if block_given?
        @@schema
      end

      def establish_connection(options={})
        ActiveRecord::Base.establish_connection({:adapter => 'sqlite3', :database => 'dst.db'}.merge(options))
      end
      
      def create_tables_if_necessary(force=false)
        ActiveRecord::Schema.define(&Dst::Models.schema) if force || !Task.table_exists?
      end
    end

    class Task < ActiveRecord::Base
      belongs_to :context
      belongs_to :project

      def self.unfinished(options={})
        find(:all, :conditions => 'status = "f"', :include => [:context, :project], :order => 't1_r1')
      end

      def self.toggle!(task_id)
        task = find(task_id)
        task.toggle!(:status)
        task
      end

      def status
        read_attribute(:status) ? 'completed' : 'unfinished'  
      end

      def to_s
        "#{id} - #{context || ''}#{project || ''}#{description}"
      end
    end

    class Context < ActiveRecord::Base
      has_many :tasks

      def to_s
        name ? "@#{name} ": ""
      end
    end

    class Project < ActiveRecord::Base
      has_many :tasks

      def to_s
        name ? ":#{name} ": ""
      end
    end
  end
end

Dst::Models.schema do
  create_table :tasks do |t|
    t.string  :description
    t.boolean :status, :default => false
    t.integer :context_id
    t.integer :project_id
    t.timestamps
  end

  create_table :contexts do |t|
    t.string :name
  end

  create_table :projects do |t|
    t.string :name
  end
end

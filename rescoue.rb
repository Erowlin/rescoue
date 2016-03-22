require 'redis'
require 'json'

class HelloJob
  def self.perform first_name, last_name
    puts "hello #{first_name} #{last_name}!"
  end
end

class SteveJob
  def self.perform
    puts "Hey, Apple!"
  end
end

class Rescoue
  def initialize options={}
  	@options = default_options.merge(options)
    @redis = Redis.new(db: 'rescoue')
  end

  def default_options
  	{
      sleep: 3
  	}
  end

  def push klass, *args
    @redis.rpush 'jobs', JSON.fast_generate(job: klass, args: args)
  end

  def pop
    job = JSON.parse(@redis.lpop 'jobs')
    # send("#{job.job}")
    Object.const_get(job['job']).perform(*job['args']) if job
  rescue
	false
  end

  def run
    loop do
      job = pop
      sleep @options[:sleep] unless job      
    end
  end
end

# rescoue = Rescoue.new sleep: 1

# rescoue.push 'HelloJob', "Jackie", "Chan"

# rescoue.push 'SteveJob'

# Rescoue.new.run
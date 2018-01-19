require "active_job/queue_adapters/qless_adapter"
require 'qless'
require 'qless/job_reservers/ordered'
require 'qless/worker'

module ActiveJobQless
  class << self
    attr_accessor :redis_uri
    attr_accessor :worker

     def initialize_worker
      self.worker = Worker.instance
    end
  end

  class Worker
    include Singleton
    attr_accessor :client

    def initialize
      set_client
    end

    def set_client
      unless @client
        if ActiveJobQless.redis_uri.nil?
          raise RuntimeError, "You must set ActiveJobQless.redis_uri"
        end
        redis_uri = URI(ActiveJobQless.redis_uri)
        options = {:host => redis_uri.host, :port => redis_uri.port}
        @client ||= Qless::Client.new(options)
        raise RuntimeError, "Qless client must be defined" if !@client
      end
    end

    def start
      queue_names = ["default"]

      # Get the queues you use
      queues = queue_names.map do |name|
        @client.queues[name]
      end

      # Create a job reserver; different reservers use different
      # strategies for which order jobs are popped off of queues
      reserver = Qless::JobReservers::Ordered.new(queues)
      # Create a forking worker that uses the given reserver to pop jobs.
      worker = Qless::Workers::SerialWorker.new(reserver, {log_level: Logger::INFO})
      # Start the worker!
      worker.run
    end
  end
end

require "qless"
require "qless/worker/base"

module ActiveJob
  module QueueAdapters
    class QlessAdapter

      def client
        @client ||= QlessClient
        raise RuntimeError, "QlessClient must be defined" unless @client
        @client
      end

      def enqueue(job) #:nodoc:
        queue = @client.queues[job.queue_name]
        job.provider_job_id = queue.put(
          job.class,
          job.serialize["arguments"],
          tags: [:perform]
          )
      end

      def enqueue_at(job, timestamp) #:nodoc:
        delay = (timestamp - Time.current.to_f).to_i
        queue = @client.queues[job.queue_name]
        job.provider_job_id = queue.put(
          job.class,
          job.serialize["arguments"],
          tags: [:perform],
          delay: delay
          )
      end

      class JobWrapper #:nodoc:
        include Qless::Workers::BaseWorker

        def perform(job_data)
          Base.execute job_data.merge("provider_job_id" => jid)
        end
      end
  end
end
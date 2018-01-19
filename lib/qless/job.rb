# monkey-patch qless, for now
require 'qless/job'

Qless::module_eval do
  class Job
    def perform
      # If we can't find the class, we should fail the job, not try to process
      begin
        klass
      rescue NameError
        return fail("#{queue_name}-NameError", "Cannot find #{klass_name}")
      end

      # log a real process executing job -- before we start processing
      log("started by pid:#{Process.pid}")

      middlewares = Job.middlewares_on(klass)

      if middlewares.last == SupportsMiddleware || ActiveJob::Callbacks::ClassMethods
        klass.around_perform(self)
      elsif middlewares.any?
        raise MiddlewareMisconfiguredError, 'The middleware chain for ' +
              "#{klass} (#{middlewares.inspect}) is misconfigured." +
              'Qless::Job::SupportsMiddleware must be extended onto your job' +
              'class first if you want to use any middleware.'
      elsif !klass.respond_to?(:perform)
        # If the klass doesn't have a :perform method, we should raise an error
        fail("#{queue_name}-method-missing",
             "#{klass_name} has no perform method")
      else
        klass.perform(self)
      end
    end
  end
end
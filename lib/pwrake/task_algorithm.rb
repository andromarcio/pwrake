module Pwrake

  module TaskAlgorithm

    # Execute the actions associated with this task.
    def pw_execute(args=nil)
      args ||= Rake::EMPTY_TASK_ARGS
      if application.options.dryrun
        #Log.info "** Execute (dry run) #{name}"
        application.trace "** Execute (dry run) #{name}"
        #puts "** Execute (dry run) #{name}"
        return
      end
      if application.options.trace
        #Log.info "** Execute #{name}"
        application.trace "** Execute #{name}"
        #puts "** Execute #{name}"
      end
      application.enhance_with_matching_rule(name) if @actions.empty?
      begin
        @actions.each do |act|
          case act.arity
          when 1
            act.call(self)
          else
            act.call(self, args)
          end
        end
      rescue Exception=>e
        raise e
      end
      @executed = true if !@actions.empty?
    end

    def pw_enq_subsequents
      t = Time.now
      #h = application.pwrake_options['HALT_QUEUE_WHILE_SEARCH']
      #application.task_queue.synchronize(h) do
        @subsequents.each do |t|        # <<--- competition !!!
          if t && t.check_prereq_finished(self.name)
            application.task_queue.enq(t)
          end
        end
      #end
      @already_finished = true        # <<--- competition !!!
    end

    def check_prereq_finished(preq_name=nil)
      @unfinished_prereq.delete(preq_name)
      @unfinished_prereq.empty?
    end

  end

end # module Pwrake
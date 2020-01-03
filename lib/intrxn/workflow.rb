module Intrxn
  class Workflow
    attr_reader :context

    def self.interactions(*interactions)
      @interactions ||= []
      opts          = interactions.pop if interactions.last.is_a?(Hash)
      @prefix       = opts.delete(:prefix) if opts
      @interactions += interactions
    end

    def self.transactions(toggle = false)
      if toggle && !const_defined?('ActiveRecord')
        raise ActiveRecordMissing, "Transactions cannot be enabled unless ActiveRecord is present"
      end
      @transactions = toggle
    end

    def initialize(context: {})
      @context = context
    end

    def interactions
      self.class.instance_variable_get(:@interactions)
    end

    def perform
      transactionally { run_interactions! }
      context
    end

    def prefix
      self.class.instance_variable_get(:@prefix)
    end

    def run_interactions!
      interactions.each { |intrxn| objectify(prefix, intrxn).new(context).process! }
    end

    private

    def transactionally(&block)
      transactions_enabled = self.class.instance_variable_get(:@transactions)
      transactions_enabled ? ActiveRecord::Base.transaction { yield } : yield
    end

    def objectify(prefix, intrxn)
      [prefix, intrxn].compact.join('/').camelcase.constantize
    end
  end
end

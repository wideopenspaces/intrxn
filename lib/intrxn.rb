require 'intrxn/version'
require 'intrxn/transaction_provider'
require 'intrxn/workflow'
require 'intrxn/interaction'

module Intrxn
  class Error < StandardError; end
  class InteractionError < Error; end
  class MissingContextError < InteractionError; end
  class MissingValueError < InteractionError; end
  class FailedCheckError < InteractionError; end

  class << self
    attr_writer :logger

    # To override, set the logger to a compatible logging library.
    # e.g, `Intrxn.logger = Rails.logger`
    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = self.name
      end
    end

    # By default, when used within Rails, ActiveRecord::Base will provide transactions.
    # Outside of Rails, Null TransactionProvider simply runs the block without transactions.
    def transaction_provider
      @transaction_provider ||= if const_defined?(TransactionProviders::ActiveRecord)
                                  TransactionProviders::ActiveRecord
                                else
                                  TransactionProviders::Null
                                end
    end

    # To override, pass a klass/module of your transaction provider as the first argument,
    # and a symbol for that provider's "transaction" method (must accept a block)
    def set_transaction_provider(provider, transaction_method)
      @transaction_provider = TransactionProvider.new(provider, transaction_method)
    end
  end
end

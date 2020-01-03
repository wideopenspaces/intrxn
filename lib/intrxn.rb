require 'intrxn/version'
require 'intrxn/workflow'
require 'intrxn/interaction'

module Intrxn
  class Error < StandardError; end
  class ActiveRecordMissing < Error; end
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
  end
end

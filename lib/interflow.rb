require 'interflow/version'
require 'interflow/workflow'
require 'interflow/interaction'

module Interflow
  class Error < StandardError; end
  class ActiveRecordMissing < Error; end
  class InteractionError < Error; end
  class MissingContextError < InteractionError; end
  class MissingValueError < InteractionError; end
  class FailedCheckError < InteractionError; end

  class << self
    attr_writer :logger

    # To override, set the logger to a compatible logging library.
    # e.g, `Interax.logger = Rails.logger`
    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = self.name
      end
    end
  end
end

module Intrxn
  class Interaction
    attr_reader :context

    # Define required elements in the context hash.
    #
    # -> needs :foo, :bar
    #
    # will create an accessor method named 'foo' that
    # provides access to context[:foo] and also raise an error
    # if the key `:foo` is not included in the context hash,
    #
    # In addition, if `:foo` does not contain a value when
    # the interaction is initialized, an error will be raised.
    # This check can be turned off:
    #
    # -> needs :foo, allow_nil: true
    #
    def self.needs(*requirements)
      @required_values ||= []
      opts              = requirements.pop if requirements.last.is_a?(Hash)
      value_optional    = opts.delete(:allow_nil) if opts

      requirements.each do |req|
        @required_values << req unless value_optional
        define_method(req) do
          raise MissingContextError, "Missing required context: #{req}" unless context.key?(req)
          context[req]
        end
      end
    end

    # Define elements the Interaction promises to add to the context
    #
    # -> promises :bar
    #
    # will raise an error if context does not include the specified key(s)
    # after the #process method has finished executing.
    # To enable this check, either call `super` on the last line of
    # your `process` method, or directly call
    # `validate_presence_of_promised_values(context)`
    #
    def self.promises(*requirements)
      @promised_values ||= Set.new
      @promised_values += requirements
    end

    # Adds a verification (like a validation). An interaction will be skipped
    # unless all verifications return true.
    #
    # Verifiers can be either Symbols or Procs (lambdas), and the with: argument
    # can take either a single Symbol or Proc, or an array of them.
    #
    # A symbol should represent a method on the interaction that will evaluate
    # the value returned by the target method and return true or false, or
    # generate an error.
    #
    # A Proc/Lambda should only return true or false
    #
    # Verifications can be run by calling verifications_pass? within the interaction.
    def self.verifies(target, with:)
      @verifications ||= {}
      @verifications[target] = Array.wrap(with)
    end

    def self.confirms(target, with:)
      @confirmations ||= {}
      @confirmations[target] = Array.wrap(with)
    end

    def self.process(&block)
      define_method(:process!) do
        instance_eval &block if block_given?
        validate_presence_of_promised_values!(context)
      end
    end

    def initialize(context = {})
      validate_presence_of_required_values!(context)
      @context = context
    end

    protected

    def validate_presence_of_required_values!(context)
      required = self.class.instance_variable_get(:@required_values) || []
      required.each do |rv|
        raise MissingValueError, "Missing required value for '#{rv}'" if context[rv].nil?
      end
    end

    def validate_presence_of_promised_values!(context)
      promised = self.class.instance_variable_get(:@promised_values) || []
      promised.each do |rv|
        raise MissingValueError, "Missing promised value for '#{rv}'" if context[rv].nil?
      end
    end

    def confirm_state_of_targets!(context)
      confirmations = self.class.instance_variable_get(:@confirmations) || []
      return true if confirmations.blank?
      confirmations.each do |target, rules|
        raise FailedCheckError, "#{target}'s state could not be confirmed." unless rules_pass?(rules, target)
      end
    end

    def run_interaction(interaction, ctx: context, key: nil)
      interaction.new(ctx).process!
      ctx[key]
    end

    def run_workflow(workflow, ctx: context, key: nil)
      workflow.new(context: ctx).process!
      ctx[key]
    end

    private

    def verifications_pass?
      verifications = self.class.instance_variable_get(:@verifications)
      return true if verifications.empty? # Skip if we have none defined.
      verifications.map { |target, rules| rules_pass?(rules, target) }.all?
    end

    def rules_pass?(rules, target)
      rules.map { |rule| rule_passes?(rule, target) }.all?
    end

    def rule_passes?(rule, target)
      case rule
      when Symbol then self.send(rule)
      when Proc   then rule.call(self.send(target))
      else
        fail 'verifies requires a block or a symbol!'
      end
    end

    def log(msg, color = nil, &_block)
      msg = msg.send(color) if color
      Intrxn.logger.info msg
      yield if block_given?
    end
  end
end

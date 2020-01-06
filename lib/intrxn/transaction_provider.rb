class TransactionProvider
  attr_reader :provider, :transaction_method

  def initialize(provider, transaction_method)
    @provider = provider
    @transaction_method = transaction_method
  end

  def transaction(&block)
    provider.send(transaction_method, &block)
  end
end

require 'intrxn/transaction_providers/active_record_provider'
require 'intrxn/transaction_providers/null_provider'

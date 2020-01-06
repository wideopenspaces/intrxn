module Intrxn
  module TransactionProviders
    class NullTransactionProvider
      def self.transaction(&block)
        yield
      end
    end

    Null = TransactionProvider.new(NullTransactionProvider, :transaction)
  end
end

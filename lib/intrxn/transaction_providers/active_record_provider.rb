module TransactionProviders
  if const_defined?('ActiveRecord') && const_defined?('ActiveRecord::Base')
    ActiveRecord = TransactionProvider.new(ActiveRecord::Base, :transaction)
  end
end

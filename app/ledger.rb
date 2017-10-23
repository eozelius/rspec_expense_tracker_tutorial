require_relative 'dependency_helper'

module ExpenseTracker
  RecordResult = Struct.new(:success?, :expense_id, :error_message)

  class Ledger
    def initialize

    end

    def record(expense)
    end

    def success?

    end



  end
end
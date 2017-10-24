require_relative 'dependency_helper'

module ExpenseTracker
  RecordResult = Struct.new(:success?, :expense_id, :error_message)
  Expense      = Struct.new(:payee, :amount, :date)

  class Ledger
    def initialize
    end

    def record(expense)
      unless expense.key?('payee')
        message = 'Invalid expense: [payee] is required'
        return RecordResult.new(false, nil, message)
      end

      DB[:expenses].insert(expense)
      id = DB[:expenses].max(:id)
      RecordResult.new(true, id, nil)
    end

    def success?
    end

    def expenses_on(date)
      DB[:expenses].where(date: date).all
    end
  end
end
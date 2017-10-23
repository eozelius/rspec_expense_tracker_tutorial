require_relative 'dependency_helper'

module ExpenseTracker
  RecordResult = Struct.new(:success?, :expense_id, :error_message)
  Expense      = Struct.new(:payee, :amount, :date)

  class Ledger
    def initialize
    end

    def record(expense)
    end

    def success?
    end

    def expenses_on(date)
      JSON.generate({ 'some' => 'expenses!!!' })
    end
  end
end
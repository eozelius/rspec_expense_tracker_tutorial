require_relative 'dependency_helper'
require_relative '../config/sequel'

module ExpenseTracker
  RecordResult = Struct.new(:success?, :expense_id, :error_message)
  Expense      = Struct.new(:payee, :amount, :date)

  class Ledger
    def initialize
    end

    def record(expense)
      unless valid_expense(expense)
        message = 'Invalid expense: [payee, amount, date] are required'
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

    private

      def valid_expense(expense)
        expense.key?("payee") && expense.key?("amount") && expense.key?("date") ? true : false
     end
  end
end
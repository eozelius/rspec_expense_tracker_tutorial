require_relative '../dependency_helper'

module ExpenseTracker
  RSpec.describe 'Expense Tracker API' do
    include Rack::Test::Methods

    def post_expense(expense)
      post '/expenses', JSON.generate(expense)
      expect(last_response.status).to eq(200)

      parsed = JSON.parse(last_response.body)
      expect(parsed).to include('expense_id' => a_kind_of(Integer))
      expense.merge('id' => parsed['expense_id'])
    end

    it 'records submitted expenses' do
      pending 'need to implement'

      def app
        ExpenseTracker::API.new
      end

      coffee = {
        'payee'   => 'Coffee Tossy',
        'amount'  => 5.75,
        'date'    => '2017-06-10'
      }

      zoo = {
        'payee'   => 'Zoo',
        'amount'  => 15.25,
        'date'    => '2017-06-10'
      }

      groceries = {
        'payee'   => 'Whole Foods',
        'amount'  => 95.20,
        'date'    => '2017-06-11'
      }

      post_expense(coffee)
      post_expense(zoo)
      post_expense(groceries)

      get '/expenses/2017-06-10'
      expect(last_response.status).to eq(200)

      october_10th = JSON.parse(last_response.body)
      expect(october_10th).to contain_exactly(coffee, zoo)
    end
  end
end
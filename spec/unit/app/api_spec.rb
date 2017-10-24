require_relative '../../../spec/dependency_helper'

module ExpenseTracker
  RSpec.describe API do
    include Rack::Test::Methods

    # SETUP
    let(:ledger)  { ExpenseTracker::Ledger.new }
    let(:expense) { { 'some' => 'data' } }
    let(:date)    { '2017-01-01' }
    let(:invalid_date) { '1999-01-01' }

    def app
      API.new(ledger: ledger)
    end

    def parsed_response
      JSON.parse(last_response.body)
    end
    # END SETUP

    describe 'GET /expenses/:date' do
      context 'when expenses exist on given date' do
        before do
          allow(ledger).to receive(:expenses_on)
            .with(date)
            .and_return(Expense.new('Coffee Tossy', 4.00, '2017-01-01'))
        end

        it 'returns the expense records as JSON' do
          post '/expenses', JSON.generate(expense)
          get "/expenses/#{date}"

          record_result = JSON.generate(Expense.new('Coffee Tossy', 4.00, '2017-01-01'))
          expect(last_response.body).to eq(record_result)
        end

        it 'responds with a 200 (OK)' do
          get "/expenses/#{date}"
          expect(last_response.status).to eq(200)
        end
      end

      context 'when there are no expenses on the given date' do
        it 'returns an empty array as JSON' do
          get "/expenses/#{invalid_date}"
          expect(parsed_response).to eq([])
        end

        it 'responds with 200 (OK)' do
          get "/expenses/#{invalid_date}"
          expect(last_response.status).to eq(200)
        end
      end
    end

    describe 'POST /expenses' do
      context 'when the expense is successful' do
        before do
          allow(ledger).to receive(:record)
             .with(expense)
             .and_return(RecordResult.new(true, 417, nil))
        end

        it 'returns the expense id' do
          post '/expenses', JSON.generate(expense)
          expect(parsed_response).to eq('expense_id' => 417)
        end

        it 'responds with a 200 (OK)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(200)
        end
      end

      context 'when the expense fails validation' do
        before do
          allow(ledger).to receive(:record)
             .with(expense)
             .and_return(RecordResult.new(false, 417, 'Expense incomplete'))
        end

        it 'returns an error message' do
          post '/expenses', JSON.generate(expense)
          expect(parsed_response).to eq('error' => 'Expense incomplete')
        end
        it 'responds with a 422 (unprocessible entity)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(422)
        end
      end
    end
  end
end
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

    def parse_response(expected_inclusion)
      parsed = JSON.parse(last_response.body)
      expect(parsed).to include(expected_inclusion)
    end

    describe 'GET /expenses/:date' do
      context 'when expenses exist on given date' do
        before do
          allow(ledger).to receive(:expenses_on)
            .with(date)
            .and_return(Expense.new('Coffee Tossy', 4.00, '2017-01-01'))
        end

        it 'returns the expense records as JSON' do
          get "/expenses/#{date}"
          parse_response([{ 'payee' => 'Coffee Tossy',
                                            'amount' => 4.00,
                                            'date' => '2017-01-01'}])
        end
        it 'responds with a 200 (OK)' do
          get "/expenses/#{date}"
          expect(last_response.status).to eq(200)
        end
      end

      context 'when there are no expenses on the given date' do
        it 'returns an empty array as JSON' do
          get "/expenses/#{invalid_date}"
          parse_response([])
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
          parse_response('expense_id' => 417)
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
          parse_response('error' => 'Expense incomplete')
        end
        it 'responds with a 422 (unprocessible entity)' do
          post '/expenses', JSON.generate(expense)
          expect(last_response.status).to eq(422)
        end
      end
    end
  end
end
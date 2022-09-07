require 'rails_helper'

RSpec.describe NewTransactionForm, type: :model do
  let(:account) { create(:account, balance_cents: 100) }
  let(:account_2) { nil }
  let(:transaction) { build(:transaction, sender: account) }
  let(:transaction_attributes) do
    {
      transaction_type: type,
      amount_cents: 50,
      message: 'message'
    }
  end
  let(:type) { %w(inbound outbound).sample }

  let(:new_transaction_form) do
    NewTransactionForm.new(
      sender: account,
      receiver: account_2,
      transaction: transaction,
      transaction_attributes: transaction_attributes
    )
  end

  describe '#save' do
    subject { new_transaction_form.save }

    context 'create succeed' do
      let(:account_2) { create(:account, balance_cents: 0) }

      it 'shoud deduct balance of sender, add to balance of receiver and create transaction with type inbound/outbound && status succeed' do
        is_expected.to be_truthy
        transaction = Transaction.first
        expect(account.reload.balance_cents).to eq(50)
        expect(account_2.reload.balance_cents).to eq(50)
        expect(transaction.message).to eq('message')
        expect(transaction.transaction_type).to eq(type)
        expect(transaction.status).to eq('succeed')
        expect(transaction.amount_cents).to eq(50)
      end
    end

    context 'when type is withdraw' do
      let(:type) { 'withdraw' }

      it 'shoud deduct balance of sender and create transaction with type withdraw && status succeed' do
        is_expected.to be_truthy
        transaction = Transaction.first
        expect(account.reload.balance_cents).to eq(50)
        expect(transaction.message).to eq('message')
        expect(transaction.transaction_type).to eq('withdraw')
        expect(transaction.status).to eq('succeed')
        expect(transaction.amount_cents).to eq(50)
      end
    end

    context 'when type is deposit' do
      let(:type) { 'deposit' }

      it 'shoud add balance of sender and create transaction with type deposit && status succeed' do
        is_expected.to be_truthy
        transaction = Transaction.first
        expect(account.reload.balance_cents).to eq(150)
        expect(transaction.message).to eq('message')
        expect(transaction.transaction_type).to eq('deposit')
        expect(transaction.status).to eq('succeed')
        expect(transaction.amount_cents).to eq(50)
      end
    end

    context 'when sender does not have enough balance' do
      before { account.update(balance_cents: 0) }
      let(:type) { 'withdraw' }

      it 'shoud create transaction with type withdraw && status failed' do
        is_expected.to be_falsy
        transaction = Transaction.first
        expect(account.reload.balance_cents).to eq(0)
        expect(transaction.message).to eq('Validation failed: Balance cents must be greater than or equal to 0')
        expect(transaction.transaction_type).to eq('withdraw')
        expect(transaction.status).to eq('failed')
        expect(transaction.amount_cents).to eq(50)
      end
    end
  end
end

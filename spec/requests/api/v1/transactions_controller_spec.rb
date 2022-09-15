# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::TransactionsController, type: :request do
  let!(:account) { create(:account, status: status, balance: 50) }
  let!(:transaction) { create(:transaction, sender: account) }
  let(:status) { 'verified' }

  describe 'get #index' do
    subject { get api_v1_account_transactions_path(account), params: params }
    
    context 'without filter params' do
      let(:params) { nil }

      it "returns list transaction" do
        subject
        body = JSON.parse(response.body)
        expect(body['status']).to eq('success')
        expect(body['data'][0]['id']).to eq(transaction.id)
        expect(body['data'][0]['message']).to be_nil
        expect(body['data'][0]['transaction_type']).to eq(transaction.transaction_type)
        expect(body['data'][0]['status']).to eq(transaction.status)
        expect(body['data'][0]['amount']).to eq(transaction.amount.format)
      end
    end

    context 'with filter params' do
      let(:params) { { transaction_type: 'withdraw' } }
      let!(:transaction_2) { create(:transaction, sender: account, transaction_type: 'withdraw', amount: 50, status: 'failed') }

      it "returns list transaction" do
        subject
        body = JSON.parse(response.body)
        expect(body)
        expect(body['status']).to eq('success')
        expect(body['data'].size).to eq(1)
        expect(body['data'][0]['id']).to eq(transaction_2.id)
        expect(body['data'][0]['message']).to be_nil
        expect(body['data'][0]['transaction_type']).to eq('withdraw')
        expect(body['data'][0]['status']).to eq('failed')
        expect(body['data'][0]['amount']).to eq(transaction_2.amount.format)
      end
    end
  end

  describe 'get #show' do
    subject { get api_v1_account_transaction_path(account, transaction) }

    it "returns detail of transaction" do
      subject
      body = JSON.parse(response.body)
      expect(body['status']).to eq('success')
      expect(body['data']['id']).to eq(transaction.id)
      expect(body['data']['message']).to be_nil
      expect(body['data']['transaction_type']).to eq(transaction.transaction_type)
      expect(body['data']['status']).to eq(transaction.status)
      expect(body['data']['amount']).to eq(transaction.amount.format)
    end
  end

  describe 'post #create' do
    subject { post api_v1_account_transactions_path(account), params: params }

    let!(:account2) { create(:account, status: status) }
    let(:params) do
      {
        transaction_type: 'inbound',
        amount: 50,
        message: 'message',
        receiver: account2.email
      }
    end

    context 'when create succeed' do
      it 'creates new transaction status succeed' do
        subject
        body = JSON.parse(response.body)
        expect(body['data']['message']).to eq('message')
        expect(body['data']['transaction_type']).to eq('inbound')
        expect(body['data']['status']).to eq('succeed')
        expect(body['data']['amount']).to eq("$50.00")
      end
    end

    context 'when create failed' do
      before { params.delete(:receiver) }

      it 'does not do any thing and return error message ' do
        expect { subject }.not_to change { Transaction.count }
        body = JSON.parse(response.body)
        expect(body['status']).to eq(400)
        expect(body['message']).to eq('Bad request')
      end
    end

    context 'when account is not verified' do
      let(:status) { %i(pending unverified).sample }

      it 'does not do any thing and return error message ' do
        subject
        body = JSON.parse(response.body)
        expect(body['status']).to eq(403)
        expect(body['message']).to eq('You do not have authorized')
      end
    end

    context 'when balance of account sender is not enough' do
      before { account.update(balance: 0) }

      it 'creates new transaction with status failed' do
        subject
        body = JSON.parse(response.body)
        expect(body['status']).to eq(400)
        expect(body['message']).to eq(["Validation failed: Balance cents must be greater than or equal to 0"])
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::AccountsController, type: :request do
  let!(:account) { create(:account) }

  describe 'get #show' do
    subject { get api_v1_account_path(account) }

    let(:data) do
      {
        id: account.id,
        email: account.email,
        first_name: account.first_name,
        last_name: account.last_name,
        phone_number: account.phone_number,
        status: account.status,
        balance: account.balance.format
      }
    end

    it "returns data of account" do
      subject
      body = JSON.parse(response.body)
      expect(body['status']).to eq('success')
      expect(body['data']).to eq(data.as_json)
    end
  end

  describe 'post #create' do
    subject { post api_v1_accounts_path, params: params }

    context 'when create succeed' do
      let(:params) do
        {
          email: 'lpdat@gmail.com.vn',
          phone_number: '0123456789',
          first_name: 'Dat',
          last_name: 'Le'
        }
      end

      it "creates new account and returns it's data" do
        expect { subject }.to change { Account.count }.from(1).to(2)
        
        body = JSON.parse(response.body)
        expect(body['status']).to eq('success')
        expect(body['data']['email']).to eq('lpdat@gmail.com.vn')
        expect(body['data']['first_name']).to eq('Dat')
        expect(body['data']['last_name']).to eq('Le')
        expect(body['data']['phone_number']).to eq('0123456789')
        expect(body['data']['status']).to eq('pending')
        expect(body['data']['balance']).to eq('$0.00')
      end
    end

    context 'when create failed' do
      let(:params) do
        {
          email: account.email,
          phone_number: '0123456789',
          first_name: 'Dat',
          last_name: 'Le'
        }
      end

      it "does not create account and return error message" do
        expect { subject }.not_to change { Account.count }
        
        body = JSON.parse(response.body)
        expect(body['status']).to eq(401)
        expect(body['message']).to eq(['Email has already been taken'])
      end
    end
  end

  describe 'put #update' do
    subject { put api_v1_account_path(account), params: params }

    let(:params) do
      {
        status: 'verified'
      }
    end

    it "updates account status" do
      expect { subject }.to change { account.reload.status }.from('pending').to('verified')
      body = JSON.parse(response.body)
      expect(body['status']).to eq('success')
      expect(body['data']['status']).to eq('verified')
    end
  end
end

# == Schema Information
#
# Table name: transactions
#
#  id               :bigint           not null, primary key
#  amount_cents     :integer          default(0), not null
#  amount_currency  :string           default("USD"), not null
#  message          :text
#  status           :integer          default("succeed")
#  transaction_type :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  receiver_id      :bigint
#  sender_id        :bigint
#
require 'rails_helper'

RSpec.describe Transaction, type: :model do
  subject(:transaction) { build(:transaction) }

  it 'has a valid factory' do
    expect(transaction).to be_valid
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:sender).class_name('Account') }
    it { is_expected.to belong_to(:receiver).class_name('Account').optional }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:transaction_type) }
    it { is_expected.to validate_presence_of(:amount_cents) }
  end

  describe 'Enums' do
    it { should define_enum_for(:status).with_values(succeed: 0, failed: 1).with_suffix }
    it { should define_enum_for(:transaction_type).with_values(inbound: 0, outbound: 1, withdraw: 2, deposit: 3).with_suffix }
  end
end

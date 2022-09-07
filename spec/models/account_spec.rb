# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id               :bigint           not null, primary key
#  balance_cents    :integer          default(0), not null
#  balance_currency :string           default("USD"), not null
#  email            :string
#  first_name       :string
#  last_name        :string
#  phone_number     :string
#  status           :integer          default("pending"), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_accounts_on_email         (email)
#  index_accounts_on_phone_number  (phone_number)
#  index_accounts_on_status        (status)
#
require 'rails_helper'

RSpec.describe Account, type: :model do
  subject(:account) { build(:account) }

  it 'has a valid factory' do
    expect(account).to be_valid
  end

  describe 'Associations' do
    it { is_expected.to have_many(:sender_transactions).with_foreign_key(:sender_id).class_name('Transaction') }
    it { is_expected.to have_many(:receiver_transactions).with_foreign_key(:receiver_id).class_name('Transaction') }
  end

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:phone_number) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_numericality_of(:balance_cents).is_greater_than_or_equal_to(0) }
    it { is_expected.to allow_values('lpdat@example.com', 'lpdat?/.-_+001@example.com').for(:email) }
    it { is_expected.not_to allow_values('lpdat@example', 'example.com', 'lpdat?/.-_001@ゴウメイガイシャ.com').for(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_uniqueness_of(:phone_number).case_insensitive }
  end

  describe 'Enum' do
    it { should define_enum_for(:status).with_values(unverified: -1, pending: 0, verified: 1).with_suffix }
  end
end

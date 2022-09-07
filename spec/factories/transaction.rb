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
FactoryBot.define do
  factory :transaction do
    association :sender, factory: :account
    association :receiver, factory: :account

    amount_cents { 100 }
    transaction_type { 'deposit' }
  end
end

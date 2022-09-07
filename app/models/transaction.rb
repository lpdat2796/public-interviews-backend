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
class Transaction < ApplicationRecord
  # Association
  belongs_to :sender, class_name: 'Account'
  belongs_to :receiver, class_name: 'Account', optional: true

  # Validate
  validates :transaction_type, :amount_cents, presence: true

  # Enum
  enum status: {
    succeed: 0,
    failed: 1
  }, _suffix: true

  enum transaction_type: {
    inbound: 0,
    outbound: 1,
    withdraw: 2,
    deposit: 3
  }, _suffix: true

  monetize :amount_cents
end

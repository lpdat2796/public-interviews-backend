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
class TransactionSerializer < ActiveModel::Serializer
  attributes :id, :message, :transaction_type, :status

  attribute :amount do
    object.amount.format
  end

  belongs_to :sender
  belongs_to :receiver
end

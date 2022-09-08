# frozen_string_literal: true

class NewTransactionForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :sender
  attribute :receiver
  attribute :transaction
  attribute :transaction_attributes

  def save
    # @transaction
    sender_balance = sender.balance
    amount = Money.from_amount(transaction_attributes[:amount].to_f, 'USD')
    transaction.assign_attributes(transaction_attributes)
    ActiveRecord::Base.transaction do
      case transaction_attributes[:transaction_type]
      when 'inbound', 'outbound'
        raise ActionController::ParameterMissing.new(params: 'receiver') if receiver.nil?
        transaction.receiver = receiver
        receiver_balance = receiver.balance
        sender.update!(balance: sender_balance - amount)
        receiver.update!(balance: receiver_balance + amount)
      when 'withdraw'
        sender.update!(balance: sender_balance - amount)
      when 'deposit'
        sender.update!(balance: sender_balance + amount)
      end

      transaction.status = :succeed
      transaction.save
    end
  rescue ActiveRecord::RecordInvalid => e
    transaction.status = :failed
    transaction.message = e.message
    transaction.save
    errors.add(:base, e.message)

    false
  end
end

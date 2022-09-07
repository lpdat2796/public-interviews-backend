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
    sender_balance = sender.balance_cents
    amount = transaction_attributes[:amount_cents].to_i
    transaction.assign_attributes(transaction_attributes)
    ActiveRecord::Base.transaction do
      case transaction_attributes[:transaction_type]
      when 'inbound', 'outbound'
        raise ActionController::ParameterMissing.new(params: 'receiver') if receiver.nil?
        transaction.receiver = receiver
        receiver_balance = receiver.balance_cents
        sender.update!(balance_cents: sender_balance - amount)
        receiver.update!(balance_cents: receiver_balance + amount)
      when 'withdraw'
        sender.update!(balance_cents: sender_balance - amount)
      when 'deposit'
        sender.update!(balance_cents: sender_balance + amount)
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

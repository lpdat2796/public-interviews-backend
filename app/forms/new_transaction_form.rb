# frozen_string_literal: true

class NewTransactionForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :sender
  attribute :receiver
  attribute :transaction
  attribute :transaction_attributes

  def save
    sender_balance = sender.balance
    amount = Money.from_amount(transaction_attributes[:amount].to_f, 'USD')
    transaction.assign_attributes(transaction_attributes)
    ActiveRecord::Base.transaction do
      calculate_balance(sender_balance, amount, transaction)
      transaction.status = :succeed
      transaction.save
    end
  rescue ActiveRecord::RecordInvalid => e
    transaction_error(e, transaction)
    errors.add(:base, e.message)

    false
  end

  private

  def calculate_transaction(sender_balance, amount, transaction)
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
  end

  def transaction_error(error, transaction)
    transaction.status = :failed
    transaction.message = error.message
    transaction.save
  end
end

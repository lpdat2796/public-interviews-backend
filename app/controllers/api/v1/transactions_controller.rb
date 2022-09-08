# frozen_string_literal: true

class Api::V1::TransactionsController < ApplicationController
  before_action :set_transaction, except: :index
  before_action :set_receiver, only: :create
  before_action :set_new_transaction_form, only: :create

  def index
    transactions = Transaction.where('sender_id = ? OR receiver_id = ?', current_account.id, current_account.id)

    if params[:transaction_type]
      transactions = transactions.where(transaction_type: params[:transaction_type])
    end

    render_response_success(
      200,
      transactions,
      each_serializer: TransactionSerializer
    )
  end

  def show
    render_response_success(
      200,
      @transaction,
      each_serializer: TransactionSerializer
    )
  end

  def create
    if !current_account.verified_status? || (@receiver.present? && !@receiver.verified_status?)
      render json: { status: 403, message: 'You do not have authorized' }
      return
    end

    if @new_transaction_form.save
      render_response_success(
        200,
        @transaction,
        each_serializer: TransactionSerializer
      )
    else
      render json: { status: 401, message: @new_transaction_form.errors.full_messages }
    end
  end

  private

  def transaction_params
    params.permit(:receiver, :transaction_type, :amount, :message)
  end

  def set_transaction
    if params[:id]
      @transaction = Transaction.find(params[:id])
    else
      @transaction = current_account.sender_transactions.new
    end
  end  

  def set_new_transaction_form
    @new_transaction_form = ::NewTransactionForm.new(
      sender: current_account,
      receiver: @receiver,
      transaction: @transaction,
      transaction_attributes: transaction_params.except(:receiver)
    )
  end

  def set_receiver
    @receiver = Account.find_by_email_or_phone_number(transaction_params[:receiver])
  end
end

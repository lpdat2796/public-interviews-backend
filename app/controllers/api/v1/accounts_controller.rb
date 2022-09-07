# frozen_string_literal: true

class Api::V1::AccountsController < ApplicationController
  def create
    account = Account.new
    account.assign_attributes(account_params)

    if account.save
      render_response_success(
        200,
        account,
        each_serializer: AccountSerializer
      )
    else
      render json: { status: 401, message: account.errors.full_messages }
    end
  end

  def show
    render_response_success(
      200,
      current_account,
      each_serializer: AccountSerializer
    )
  end

  def update
    if current_account.update(status: params[:status])
      render_response_success(
        200,
        current_account,
        each_serializer: AccountSerializer
      )
    else
      render json: { status: 401, message: current_account.errors.full_messages }
    end
  end

  private

  def account_params
    params.permit(:first_name, :last_name, :email, :phone_number)
  end
end

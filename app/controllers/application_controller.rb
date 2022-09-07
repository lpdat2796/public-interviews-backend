# frozen_string_literal: true

class ApplicationController < ActionController::API
  include SerializerHelper

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: { status: 404, message: 'Record not found' }
  end

  rescue_from ActionController::ParameterMissing do |exception|
    render json: { status: 400, message: 'Bad request' }
  end

  def current_account
    id = params[:account_id] || params[:id]
    @account = Account.find(id)
  end
end

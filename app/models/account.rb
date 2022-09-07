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
class Account < ApplicationRecord
  # Association
  has_many :sender_transactions, foreign_key: :sender_id, class_name: 'Transaction'
  has_many :receiver_transactions, foreign_key: :receiver_id, class_name: 'Transaction'

  # Valdation
  EMAIL_REGEXP = %r{\A[0-9a-z_./?+-]+@([0-9a-z-]+\.)+[0-9a-z-]+\z}

  validates :first_name, :last_name, :email, :phone_number, :balance_cents, presence: true
  validates :email, format: { with: EMAIL_REGEXP }
  validates :email, :phone_number, uniqueness: { case_sensitive: false }
  validates_numericality_of :balance_cents, greater_than_or_equal_to: 0

  enum status: {
    unverified: -1,
    pending: 0,
    verified: 1
  }, _suffix: true

  monetize :balance_cents

  def self.find_by_email_or_phone_number(params)
    find_by('email = ? OR phone_number = ?', params, params)
  end
end

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
class AccountSerializer < ActiveModel::Serializer
  attributes :id, :email, :first_name, :last_name, :phone_number, :status

  attribute :balance do
    "#{object.balance_cents} #{object.balance_currency}"
  end
end

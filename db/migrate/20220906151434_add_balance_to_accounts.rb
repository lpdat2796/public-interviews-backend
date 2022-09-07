class AddBalanceToAccounts < ActiveRecord::Migration[6.0]
  def change
    add_monetize :accounts, :balance
  end
end

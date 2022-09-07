class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
      t.bigint :sender_id
      t.bigint :receiver_id
      t.integer :transaction_type, null: false
      t.integer :status, default: 0
      t.monetize :amount, default: 0
      t.text :message

      t.timestamps
    end
  end
end

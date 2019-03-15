class CreateVoucher < ActiveRecord::Migration[5.0]
  def change
    create_table :vouchers do |t|
      t.integer  :order_id
      t.datetime :start_at
      t.datetime :end_at
      t.integer  :amount
      t.string   :code
      t.string   :aasm_state, default: "valid_no_used"
      t.timestamps
    end

    add_index  :vouchers, :aasm_state
    add_column :orders, :voucher_code,   :string
    add_column :orders, :voucher_amount, :integer

  end
end

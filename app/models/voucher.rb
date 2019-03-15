class Voucher < ApplicationRecord

  include AASM

  validates :start_at, :end_at, :amount, presence: true

  belongs_to :order, optional: true

  before_create :generate_code

  aasm do
    state :valid_no_used, initial: true
    state :valid_used
    state :invalid

    event :used do
      transitions form: :valid_no_used,  to: :valid_used
    end

    event :cancel, after_commit: :update_order_id! do
      transitions from: :valid_used,     to: :valid_no_used
    end

    event :admin_valid do
      transitions from: :valid_no_used,   to: :invalid
    end

    event :admin_invalid do
      transitions from: :invalid,        to: :valid_no_used
    end
  end


  def generate_code
    self.code = SecureRandom.hex(4)
  end

  def update_order_id!
    self.update_columns(order_id: "")
  end

  def aasm_state_name(aasm_state)
    case aasm_state
      when "valid_no_used"
        "待使用"
      when "valid_used"
        "已使用"
      when "invalid"
        "无效"
    end
  end

end

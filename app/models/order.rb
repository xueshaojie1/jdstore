class Order < ApplicationRecord

  include AASM

  validates :billing_name, :billing_address, :shipping_name, :shipping_address, presence: true

  belongs_to :user
  has_one :voucher
  has_many :product_lists

  before_create :generate_token
  after_create  :update_voucher

  aasm do
    state :order_placed, initial: true
    state :paid
    state :shipping
    state :shipped
    state :order_cancelled
    state :good_returned

    event :make_payment, after_commit: :pay! do
      transitions from: :order_placed, to: :paid
    end

    event :ship do
      transitions form: :paid,         to: :shipping
    end

    event :deliver do
      transitions from: :shipping,     to: :shipped
    end

    event :return_good do
      transitions from: :shipped,      to: :good_returned
    end

    event :cancel_order do
      transitions from: [:order_placed, :paid], to: :order_cancelled
    end

  end

  def generate_token
    self.token = SecureRandom.uuid
  end

  def set_payment_with!(method)
    self.update_columns(payment_method: method )
  end

  def pay!
    self.update_columns(is_paid: true )
  end

  def update_voucher
    @voucher = Voucher.where(code: voucher_code, aasm_state: "valid_no_used").first rescue nil
    self.update(voucher_amount: @voucher.amount) if @voucher.present? && @voucher.start_at <= created_at && @voucher.end_at >= created_at && total > @voucher.amount

    if voucher_amount.present?
      self.update(total: total - voucher_amount)
      @voucher.used!
      @voucher.update(order_id: id)
    end
  end

  def aasm_state_name(aasm_state)
    case aasm_state
      when "order_placed"
        "待支付"
      when "paid"
        "已支付"
      when "shipping"
        "待发货"
      when "shipped"
        "已发货"
      when "order_cancelled"
        "已取消"
      when "good_returned"
        "已退货"
    end
  end

  def total_amount
    total.to_i + voucher_amount.to_i
  end
end

class CartsController < ApplicationController

  def clean
    current_cart.clean!
    flash[:warning] = "已清空购物车"
    redirect_to carts_path
  end

  def checkout
    @order = Order.new
  end

  def voucher_amount
    @voucher = Voucher.where(code: params[:voucher_code], aasm_state: "valid_no_used").first rescue nil
    now_time = Time.now
    is_voucher = @voucher.present? && now_time >= @voucher.start_at &&  now_time <= @voucher.end_at
    render json: {code: 200, message: is_voucher ? "优惠金额：#{@voucher.amount}" : "没有对应的优惠码或者优惠码不在有效范围内" }
  end

end

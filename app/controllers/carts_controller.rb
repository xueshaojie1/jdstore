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
    @voucher = Voucher.where(code: params[:voucher_code], aasm_state: "valid_no_used").first
    render json: {code: 200, message: @voucher.present? ? "优惠金额：#{@voucher.amount}" : "没有对应的优惠码" }
  end

end

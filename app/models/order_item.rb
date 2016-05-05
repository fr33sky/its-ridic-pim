class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product
  before_save :set_average_cost

  private

  def last_order_average_cost
    last_order = Order.joins(:order_items).where("product_id = ?", self.product_id).order("user_date DESC").first
    OrderItem.where("order_id = ? AND product_id = ?", last_order.id, self.product_id).first.average_cost
  end

  def last_quantity
    # Anything ordered, sold, and adjusted prior to this order
    ordered  = OrderItem.joins(:order).where("product_id = ? AND user_date < ?", self.product_id, self.order.user_date).sum(:quantity)
    sold     = Sale.where("product_id = ? AND created_at < ?", self.product_id, self.order.user_date).sum(:quantity)
    adjusted = Adjustment.where("product_id = ? AND created_at < ?", self.product_id, self.order.user_date).sum(:adjusted_quantity)
    ordered - sold + adjusted
  end

  def set_average_cost
    product = Product.find(self.product_id)
    if self.order.created_at == self.order.user_date
      if product.item_ordered?
        self.average_cost = (cost + (product.on_hand * last_order_average_cost)) / (product.on_hand + quantity)
      else
        self.average_cost = cost / quantity
      end
    else
      # oops order
      self.average_cost = ((last_order_average_cost * last_quantity) + self.cost) / ( last_quantity + self.quantity )
    end
  end
end

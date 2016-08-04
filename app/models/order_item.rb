class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product
  before_save :set_average_cost


  def last_order_average_cost
    begin
      return OrderItem.joins(:order).where("product_id = ? AND user_date < ?", self.product.id, self.order.user_date).order("user_date DESC").first.average_cost
    rescue
      return 0.00
    end
  end

  def last_quantity(oi=self)
    # Anything ordered, sold, and adjusted prior to this order
    ordered  = OrderItem.joins(:order).where("product_id = ? AND user_date < ?", oi.product_id, oi.order.user_date).sum(:quantity)
    sold     = SalesReceipt.joins(:sales).where("product_id = ? AND user_date < ?", oi.product_id, oi.order.user_date).sum(:quantity)
    adjusted = Adjustment.where("product_id = ? AND created_at < ?", oi.product_id, oi.order.user_date).sum(:adjusted_quantity)
    ordered - sold + adjusted
  end

  def set_average_cost
    self.order.save
    product = Product.find(self.product_id)
    if self.order.created_at == self.order.user_date
      if product.item_ordered?
        self.average_cost = (cost + (product.on_hand * last_order_average_cost)) / (product.on_hand + quantity)
      else
        self.average_cost = cost / quantity
      end
    else
      # oops order
      # Are there any orders after this oops order?  If so, must update them too
      if OrderItem.joins(:order).where("product_id = ? AND user_date > ?", self.product_id, self.order.user_date).count > 0
        # If so, must update current AVCO and then update all ones after that one.
        self.average_cost = ((last_order_average_cost * last_quantity) + self.cost) / ( last_quantity + self.quantity )
        after_orders = OrderItem.joins(:order).where("product_id = ? AND user_date > ?", 
                                      self.product_id, self.order.user_date).order("user_date ASC")
        after_orders.each_with_index do |oi, index|
          if index == 0
            avco = ((self.average_cost * (last_quantity + self.quantity)) + oi.cost) / ( (last_quantity +  self.quantity) + oi.quantity )
            oi.update_column(:average_cost, avco)
          else
            avco = ((after_orders[index - 1].average_cost * (last_quantity(oi) + after_orders[index - 1].quantity)) + oi.cost) / ( (last_quantity(oi) +  after_orders[index - 1].quantity) + oi.quantity )
            oi.update_column(:average_cost, avco)
          end
        end
      else
        # If not, just update using the last order
        self.average_cost = ((last_order_average_cost * last_quantity) + self.cost) / ( last_quantity + self.quantity )
      end
      #self.average_cost = ((last_order_average_cost * last_quantity) + self.cost) / ( last_quantity + self.quantity )
    end
  end
end

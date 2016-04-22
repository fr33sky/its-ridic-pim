class Product < ActiveRecord::Base

  def quantity_ordered
    OrderItem.where("product_id = ?", self.id).sum(:quantity)
  end

  def quantity_sold
    Sale.where("product_id = ?", self.id).sum(:quantity)
  end

  def quantity_adjusted
    Adjustment.where("product_id = ?", self.id).sum(:adjusted_quantity)
  end

  def on_hand
    quantity_ordered - quantity_sold + quantity_adjusted
  end
end

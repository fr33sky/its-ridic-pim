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

  def last_quantity_ordered
    if item_ordered?
      OrderItem.where("product_id = ?", self.id).last.quantity
    else
      0
    end
  end

  def last_cost
    if item_ordered?
      OrderItem.where("product_id = ?", self.id).last.cost / 
        OrderItem.where("product_id = ?", self.id).last.quantity
    else
      0
    end
  end

  def item_ordered?
    if OrderItem.where("product_id = ?", self.id).size != 0
      true
    else
      false
    end
  end

  def average_cost(date)
    if item_ordered?
      OrderItem.joins(:order).where("product_id = ? AND user_date < ?", self.id, date).order("user_date DESC").first.average_cost
    else
      0
    end
  end
end

class Product < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :upc, presence: true, uniqueness: true
  validates :price, presence: true
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
      OrderItem.joins(:order).where("product_id = ? AND user_date < ?", self.id, date).order("user_date DESC").first.try(:average_cost) || 0
    else
      0
    end
  end

  def self.get_product_report_from_amazon(client, report_request_id)
    puts "get_product_report_from_amazon..."
    status = ""
    while status != "_DONE_"
      response = client.get_report_request_list(report_request_id_list: [report_request_id]).parse
      p response
      status = response["ReportRequestInfo"]["ReportProcessingStatus"]
      puts "status=#{status}"
      if status == "_DONE_"
        report_id = response["ReportRequestInfo"]["GeneratedReportId"]
        product_csv = client.get_report(report_id).parse
        parse_product_report(product_csv)
      end
      puts "Sleeping..."
      sleep 300
    end
  end

  private

  def parse_product_report(product_csv)
    puts "DONE!"
    p product_csv
  end
end

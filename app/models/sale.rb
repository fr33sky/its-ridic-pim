class Sale < ActiveRecord::Base
  belongs_to :product
  belongs_to :sales_receipt
  after_save :set_rate

  private

  def set_rate
    if self.rate.blank?
      self.update_column(:rate, amount.to_f / quantity)
    end
  end
end

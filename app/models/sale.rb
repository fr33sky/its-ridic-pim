class Sale < ActiveRecord::Base
  belongs_to :product
  belongs_to :payment
  belongs_to :contact
  after_save :set_rate

  private

  def set_rate
    self.update_column(:rate, amount / quantity)
  end

end

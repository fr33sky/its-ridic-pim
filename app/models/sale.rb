class Sale < ActiveRecord::Base
  belongs_to :product
  belongs_to :payment
  belongs_to :contact
  after_save :set_user_date

  private

  def set_user_date
    if user_date.blank?
      self.update_column(:user_date, self.created_at)
    end
  end
end

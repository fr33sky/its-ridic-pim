class Order < ActiveRecord::Base
  belongs_to :contact
  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items, reject_if: :all_blank, allow_destroy: true
  after_save :set_user_date

  private

  def set_user_date
    if user_date.nil?
      self.update_column(:user_date, self.created_at)
    end
  end
end

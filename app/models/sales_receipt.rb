class SalesReceipt < ActiveRecord::Base
  belongs_to :contact
  belongs_to :payment
  has_many :sales, dependent: :destroy
  accepts_nested_attributes_for :sales, reject_if: :all_blank, allow_destroy: true
  after_save :set_user_date

  validates :contact, presence: true
  validates :payment, presence: true

  def total
    self.sales.sum(:amount)
  end

  private

  def set_user_date
    if user_date.blank?
      self.update_column(:user_date, self.created_at)
    end
  end
end

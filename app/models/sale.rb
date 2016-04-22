class Sale < ActiveRecord::Base
  belongs_to :product
  belongs_to :payment
  belongs_to :contact
end

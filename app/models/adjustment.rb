class Adjustment < ActiveRecord::Base
  belongs_to :product
  belongs_to :adjustment_type
end

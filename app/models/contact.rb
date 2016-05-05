class Contact < ActiveRecord::Base
  def to_s
    name
  end
end

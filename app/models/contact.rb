class Contact < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :name, presence: true
  validates :email_address, presence: true, length: { maximum: 255 },
                          format: { with: VALID_EMAIL_REGEX }
  def to_s
    name
  end
end

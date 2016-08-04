class Contact < ActiveRecord::Base
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :name, presence: true
  validates :email_address, length: { maximum: 255 },
                          format: { with: VALID_EMAIL_REGEX },
                          allow_blank: true
  def to_s
    name
  end
end

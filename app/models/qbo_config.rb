class QboConfig < ActiveRecord::Base
  def exists?
    if QboConfig.count == 0
      false
    else
      true
    end
  end

  def add_or_update_config(token, secret, realm_id)
    if self.exists?
      QboConfig.new(token: token, secret: secret, realm_id: realm_id)
    else
      QboConfig.first.update!(token: token, secret: secret, realm_id: realm_id)
    end
  end

  def self.token
    QboConfig.first.token
  end

  def self.secret
    QboConfig.first.secret
  end

  def self.realm_id
    QboConfig.first.realm_id
  end
end

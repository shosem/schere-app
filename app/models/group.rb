class Group < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  before_create :generate_token

  private
  def generate_token
    token = SecureRandom.urlsafe_base64(16)
    while Group.exists?(join_token: token)
      token = SecureRandom.urlsafe_base64(16)
    end
    self.join_token = token
  end

end

class Group < ApplicationRecord
  belongs_to :user
  has_many :guests

  validates :name, presence: true
  before_create :generate_join_token

  private
  def generate_join_token
    token = SecureRandom.urlsafe_base64(16)
    while Group.exists?(join_token: token)
      token = SecureRandom.urlsafe_base64(16)
    end
    self.join_token = token
  end
end

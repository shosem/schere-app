class Guest < ApplicationRecord
  belongs_to :group
  has_many :votes, as: :voter, dependent: :destroy
  validates :name, length: { maximum: 10 }, presence: true
  before_create :generate_session_token

  private

  def generate_session_token
    token = SecureRandom.urlsafe_base64(16)
    while Guest.exists?(session_token: token)
      token = SecureRandom.urlsafe_base64(16)
    end
    self.session_token = token
  end
end

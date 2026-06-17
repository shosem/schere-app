require 'rails_helper'

RSpec.describe User, type: :model do
  context '作成可能' do
    it '有効なユーザーが作成できること' do
      user = create(:user)
      expect(user).to be_valid
    end
  end
  
  context '作成失敗' do
    it '名前が空白の場合' do
      user = build(:user, name: "")
      expect(user).to be_invalid
    end

    it 'メールアドレスが空白の場合' do
      user = build(:user, email: "")
      expect(user).to be_invalid
    end

    it 'パスワードが空白の場合' do
      user = build(:user, password: "")
      expect(user).to be_invalid
    end

    it 'メールアドレスが重複する場合' do
      user1 = create(:user)
      pp user1.email
      user2 = build(:user, name: "dup_user", email: user1.email)
      pp user2.email
      expect(user2).to be_invalid
    end
  end
end

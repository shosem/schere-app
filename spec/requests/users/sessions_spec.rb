require 'rails_helper'

RSpec.describe "User::Sessions", type: :request do
  describe "ログイン" do
    let(:user) { create(:user) }

    it "ログインできること" do
      post user_session_path, params: {
        user: { email: user.email, password: user.password }
      }
      expect(response).to redirect_to(root_path)
    end

    it "ログアウトできること" do
      sign_in user
      delete destroy_user_session_path
      expect(response).to redirect_to(root_path)
    end
  end
end

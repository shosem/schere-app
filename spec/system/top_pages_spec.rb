require 'rails_helper'

RSpec.describe "TopPages", type: :system do
  include LoginMacros

  describe "トップページ" do
    context "未ログインの場合" do
      it "トップページにアクセスするとログイン画面へ遷移すること" do
        visit root_path
        expect(page).to have_current_path(new_user_session_path)
        expect(page).to have_content("ログインもしくはアカウント登録してください")
      end
    end

    context "ログインしている場合" do
      let(:user) { create(:user) }

      it "トップページにアクセスできること" do
        login(user)
        expect(page).to have_current_path(root_path)
      end
    end
  end
end

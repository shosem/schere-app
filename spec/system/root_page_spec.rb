require 'rails_helper'

RSpec.describe "RootPage", type: :system do
  include LoginMacros

  context "未ログインの場合" do
    it "root_pathにアクセスするとログイン画面へ遷移すること" do
      visit root_path
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content("ログインもしくはアカウント登録してください")
    end
  end

  context "ログインしている場合" do
    let(:user) { create(:user) }

    it "root_pathにアクセスできること" do
      login(user)
      expect(page).to have_current_path(root_path)
    end
  end
end

require 'rails_helper'

RSpec.describe "Headers", type: :system do
  include LoginMacros

  describe "ログイン状態によるヘッダーの画面表示と遷移" do
    context "ログイン時" do
      let(:user) { create(:user) }

      before do
        login(user)
      end

      it "名前の頭文字のアイコンが表示されること" do
        expect(page).to have_button(user.name.first)
        expect(page).to have_no_link("ログイン")
      end

      it "名前の頭文字のアイコンをクリックし、開いたドロップダウンメニューからログアウトできること" do
        click_button(user.name.first)
        click_on("ログアウト")
        expect(page).to have_current_path(new_user_session_path)
        expect(page).to have_content("ログアウトしました")
        expect(page).to have_link("ログイン")
      end
    end

    context "未ログイン時" do
      before do
        visit root_path
      end

      it "新規登録とログインのリンクが表示されていること" do
        expect(page).to have_link("新規登録")
        expect(page).to have_link("ログイン")
      end

      it "新規登録画面に遷移できること" do
        click_link "新規登録"
        expect(page).to have_current_path(new_user_registration_path)
      end

      it "ログイン画面に遷移できること" do
        click_link "ログイン", match: :first
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end
end

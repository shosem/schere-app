require 'rails_helper'

RSpec.describe "Headers", type: :system do
  include LoginMacros

  describe "ログイン状態によるヘッダーの画面表示と遷移" do
    let(:user) { create(:user) }
    context "ログイン時" do
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
      end
    end

    context "未ログイン時" do
      before do
        visit root_path
      end

      it "ログイン画面に遷移すること" do
        expect(page).to have_current_path(new_user_session_path)
        expect(page).to have_content("ログイン")
      end

      it "ログイン画面でヘッダーが表示されていないこと" do
        visit new_user_session_path
        expect(page).to have_no_link("Schere")
        expect(page).to have_no_link(new_user_session_path)
      end

      it "新規登録画面でヘッダーが表示されていないこと" do
        visit new_user_registration_path
        expect(page).to have_no_link("Schere")
        expect(page).to have_no_button(user.name.first)
      end
    end
  end
end

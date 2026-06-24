require 'rails_helper'

RSpec.describe "Footers", type: :system do
  include LoginMacros

  describe "フッター" do
    let(:user) { create(:user) }

    context "スマホレイアウトの場合" do
      before do
        page.current_window.resize_to(375, 667)
        login(user)
      end

      it "スマホ用のタブバーが表示されていること" do
        expect(page).to have_content("ダッシュボード")
        expect(page).to have_content("設定")
      end

      it "PC用のフッターが表示されていないこと" do
        expect(page).to have_no_content("© 2026 Schere")
      end

      it "左ホームアイコンを押すとルートページに遷移すること" do
        click_on "ダッシュボード"
        expect(page).to have_current_path(root_path)
      end

      it "右設定アイコンを押すとアカウント編集ページに遷移すること" do
        click_on "設定"
        expect(page).to have_current_path(edit_user_registration_path)
      end
    end

    context "PCレイアウトの場合" do
      before do
        page.current_window.resize_to(1680, 1050)
        login(user)
      end

      it "PC用のフッターが表示されていること" do
        expect(page).to have_content("© 2026 Schere")
      end

      it "スマホ用のタブバーが表示されていないこと" do
        expect(page).to have_no_content("ダッシュボード")
        expect(page).to have_no_content("設定")
      end
    end

    context "ログイン画面の場合" do
      before do
        visit new_user_session_path
      end

      it "フッターが表示されていないこと" do
        expect(page).to have_no_content("© 2026 Schere")
        expect(page).to have_no_content("ダッシュボード")
        expect(page).to have_no_content("設定")
      end
    end
  end

  describe "認証画面のフッター表示" do
    context "新規作成画面の場合" do
      before do
        visit new_user_registration_path
      end

      it "フッターが表示されていないこと" do
        expect(page).to have_no_content("© 2026 Schere")
        expect(page).to have_no_content("ダッシュボード")
        expect(page).to have_no_content("設定")
      end
    end
  end
end

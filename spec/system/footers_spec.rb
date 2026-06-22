require 'rails_helper'

RSpec.describe "Footers", type: :system do
  include LoginMacros

  describe "フッター" do
    context "スマホレイアウト時の場合" do
      let(:user) { create(:user) }

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
  end
end

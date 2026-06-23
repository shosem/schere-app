require 'rails_helper'

RSpec.describe "Edits", type: :system do
  include LoginMacros

  let(:user) { create(:user) }

  before do
    login(user)
    visit edit_user_registration_path
  end

  describe "アカウント情報編集機能" do
    context "編集可能" do
      it "メールアドレスを変更できること" do
        fill_in "Eメール", with: "change#{user.email}"
        fill_in "現在のパスワード", with: "pass"
        click_on "更新"
        expect(page).to have_current_path(root_path)
        expect(page).to have_content("アカウント情報を変更しました")
      end

      it "パスワードを変更できること" do
        fill_in "Eメール", with: user.email
        fill_in "パスワード", with: "password"
        fill_in "パスワード（確認用）", with: "password"
        fill_in "現在のパスワード", with: "pass"
        click_on "更新"
        expect(page).to have_current_path(root_path)
        expect(page).to have_content("アカウント情報を変更しました")
      end
    end

    context "編集不可" do
      it "現在のパスワードを間違えるとメールアドレスを変更できないこと" do
        fill_in "Eメール", with: "change#{user.email}"
        fill_in "現在のパスワード", with: "notpass"
        click_on "更新"
        expect(page).to have_current_path(edit_user_registration_path)
        expect(page).to have_content("保存されませんでした。")
      end

      it "現在のパスワードを間違えるとパスワードを変更できないこと" do
        fill_in "Eメール", with: user.email
        fill_in "パスワード", with: "password"
        fill_in "パスワード（確認用）", with: "password"
        fill_in "現在のパスワード", with: "notpass"
        click_on "更新"
        expect(page).to have_current_path(edit_user_registration_path)
        expect(page).to have_content("保存されませんでした。")
      end
    end
  end

  describe "アカウント削除機能" do
    it "アカウントを削除できること" do
      page.accept_confirm do
        click_on "アカウント削除"
      end
      expect(page).to have_current_path(new_user_session_path)
      only_login(user)
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content("Eメールまたはパスワードが違います。")
    end
  end
end

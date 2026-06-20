require 'rails_helper'

RSpec.describe "Sessions", type: :system do
  describe "ログイン機能" do
    before do
      visit new_user_session_path
    end

    let(:user) { create(:user) }
  
    context "ログイン可能" do
      it "ログインできること" do
        fill_in "Eメール", with: user.email
        fill_in "パスワード", with: "pass"
        click_on "ログイン"
        expect(page).to have_current_path(root_path)
        expect(page).to have_content("ログインしました。")
      end
    end

    context "ログイン不可能" do
      it "間違ったメールアドレスを入力するとログインできないこと" do
        fill_in "Eメール", with: "non-#{user.email}"
        fill_in "パスワード", with: "pass"
        click_on "ログイン"
        expect(page).to have_current_path(new_user_session_path)
        expect(page).to have_content("Eメールまたはパスワードが違います。")
      end

      it "間違ったパスワードを入力するとログインできないこと" do
        fill_in "Eメール", with: user.email
        fill_in "パスワード", with: "nonpass"
        click_on "ログイン"
        expect(page).to have_current_path(new_user_session_path)
        expect(page).to have_content("Eメールまたはパスワードが違います。")
      end
    end
  end

  describe "画面遷移" do
    it "新規登録画面に遷移できること" do
      visit new_user_session_path
      click_link "アカウントを作る！"
      expect(page).to have_current_path(new_user_registration_path)
      expect(page).to have_content("アカウント登録")
    end
  end
end

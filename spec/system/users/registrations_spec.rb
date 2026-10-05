require 'rails_helper'

RSpec.describe "Registrations", type: :system do
  describe "ユーザー新規作成機能" do
    before do
      visit new_user_registration_path
    end

    context "作成可能" do
      it "新規登録できること" do
        fill_in "名前", with: "テストくん"
        fill_in "Eメール", with: "test@example.com"
        fill_in "パスワード", with: "password"
        fill_in "パスワード（確認用）", with: "password"
        click_on "登録"
        expect(page).to have_current_path(root_path)
        expect(page).to have_content("アカウント登録が完了しました")
      end
    end

    context "作成不可" do
      it "名前の入力欄が空白だと保存できないこと" do
        fill_in "Eメール", with: "test@example.com"
        fill_in "パスワード", with: "password"
        fill_in "パスワード（確認用）", with: "password"
        click_on "登録"
        expect(page).to have_current_path(new_user_registration_path)
        expect(page).to have_content("アカウント登録")
        expect(page).to have_content("名前を入力してください")
      end

      it "Eメールの入力欄が空白だと保存できないこと" do
        fill_in "名前", with: "テストくん"
        fill_in "パスワード", with: "password"
        fill_in "パスワード（確認用）", with: "password"
        click_on "登録"
        expect(page).to have_current_path(new_user_registration_path)
        expect(page).to have_content("アカウント登録")
        expect(page).to have_content("Eメールを入力してください")
      end

      it "パスワードの入力欄が空白だと保存できないこと" do
        fill_in "名前", with: "テストくん"
        fill_in "Eメール", with: "test@example.com"
        click_on "登録"
        expect(page).to have_current_path(new_user_registration_path)
        expect(page).to have_content("アカウント登録")
        expect(page).to have_content("パスワードを入力してください")
      end

      it "パスワードとパスワード(確認)の入力が一致しないと保存できないこと" do
        fill_in "名前", with: "テストくん"
        fill_in "Eメール", with: "test@example.com"
        fill_in "パスワード", with: "password"
        fill_in "パスワード（確認用）", with: "password2"
        click_on "登録"
        expect(page).to have_current_path(new_user_registration_path)
        expect(page).to have_content("アカウント登録")
        expect(page).to have_content("パスワード（確認用）とパスワードの入力が一致しません")
      end
    end

    # 認証画面は auth レイアウトでヘッダーもフッターも無い。
    # 登録前に規約とポリシーを読む経路はこの同意文だけなので、遷移まで確かめる。
    describe "同意文" do
      it "同意文と2ページへのリンクが表示されること" do
        expect(page).to have_content("登録することで")
        expect(page).to have_content("に同意したものとみなします")
        expect(page).to have_link("利用規約", href: terms_path)
        expect(page).to have_link("プライバシーポリシー", href: privacy_path)
      end

      it "利用規約へ遷移できること" do
        click_link "利用規約"
        expect(page).to have_current_path(terms_path)
      end

      it "プライバシーポリシーへ遷移できること" do
        click_link "プライバシーポリシー"
        expect(page).to have_current_path(privacy_path)
      end
    end
  end
end

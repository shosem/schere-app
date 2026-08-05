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

      context "名前の頭文字アイコンをクリックし、ドロップダウンを開いた状態" do
        before do
          click_button(user.name.first)
        end

        it "ログアウトできること" do
          click_on("ログアウト")
          expect(page).to have_current_path(new_user_session_path)
          expect(page).to have_content("ログアウトしました")
        end

        it "アカウント設定ページに遷移できること" do
          click_on("アカウント設定")
          expect(page).to have_current_path(edit_user_registration_path)
          expect(page).to have_content("アカウント情報の変更")
        end

        it "グループ作成ページに遷移できること" do
          click_on("グループ作成")
          expect(page).to have_current_path(new_group_path)
          expect(page).to have_content("グループを作成する")
        end

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

    context "ゲスト入室時" do
      let(:group) { create(:group) }
      before do
        visit new_group_join_path(group.join_token)
        fill_in "ゲスト名", with: "テストさん"
        click_on "参加する"
      end

      it "ロゴがリンク化されていないこと" do
        expect(page).to have_no_link("Schere")
      end

      it "グループ名が表示されていること" do
        expect(page).to have_content(group.name), match: :first
      end

      it "ゲスト名が表示されていること" do
        expect(page).to have_content("テストさん"), match: :first
      end
    end

    context "ゲスト入室後、ユーザーとしてログインした場合" do
      let(:group) { create(:group) }
      before do
        visit new_group_join_path(group.join_token)
        fill_in "ゲスト名", with: "テストさん"
        click_on "参加する"
      end

      it "ログイン時のヘッダーが表示されること" do
        login(user)
        expect(page).to have_button(user.name.first)
        expect(page).to have_no_link("ログイン")
      end
    end
  end
end

require 'rails_helper'

RSpec.describe "Headers", type: :system do
  include LoginMacros

  # ゲスト用のハンバーガーは svg だけで、押せる名前を持たないため属性で拾う
  def open_guest_menu
    find('button[data-action="click->dropdown#toggle"]').click
  end

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
        within("header") do
          expect(page).to have_content(group.name)
        end
      end

      context "グループ名が長い場合" do
        let(:group) { create(:group, name: "あ" * 20) }

        it "ヘッダーでは10文字（7文字＋…）に省略されること" do
          within("header") do
            expect(page).to have_content("あああああああ...")
            expect(page).to have_no_content("ああああああああ")
          end
        end
      end

      it "ドロップダウンは閉じた状態で表示されること" do
        expect(page).to have_no_content("テストさん")
        expect(page).to have_no_link("ユーザー登録")
        expect(page).to have_no_link("ログイン")
        expect(page).to have_no_button("退室する")
      end

      context "ハンバーガーメニューをクリックし、ドロップダウンを開いた状態" do
        before do
          open_guest_menu
        end

        it "ゲスト名と3つの導線が表示されること" do
          expect(page).to have_content("テストさん")
          expect(page).to have_link("ユーザー登録")
          expect(page).to have_link("ログイン")
          expect(page).to have_button("退室する")
        end

        it "メニューの外をクリックすると閉じること" do
          find(".page-header", text: group.name).click
          expect(page).to have_no_link("ユーザー登録")
          expect(page).to have_no_button("退室する")
        end

        it "ユーザー登録ページに遷移できること" do
          click_on "ユーザー登録"
          expect(page).to have_current_path(new_user_registration_path)
          expect(page).to have_content("アカウント登録")
        end

        it "ログインページに遷移できること" do
          click_on "ログイン"
          expect(page).to have_current_path(new_user_session_path)
        end

        describe "退室" do
          it "入室ページに戻り、退室した旨が表示されること" do
            click_on "退室する"
            expect(page).to have_current_path(new_group_join_path(group.join_token))
            expect(page).to have_content("退室しました")
          end

          it "退室後はグループ詳細にアクセスできないこと" do
            click_on "退室する"
            expect(page).to have_content("退室しました") # 退室の完了を待ってから次のページへ
            visit group_path(group)
            expect(page).to have_current_path(new_user_session_path)
          end

          # 名前を間違えて入室した人が、入り直せること
          it "退室後、別の名前で入室できること" do
            click_on "退室する"
            fill_in "ゲスト名", with: "べつのなまえ"
            click_on "参加する"
            expect(page).to have_content("#{group.name}にべつのなまえさんとして入室しました")
            expect(Guest.count).to eq 2
          end
        end
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

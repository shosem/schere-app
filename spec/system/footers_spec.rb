require 'rails_helper'

RSpec.describe "Footers", type: :system do
  include LoginMacros

  describe "フッター" do
    let(:user) { create(:user) }
    let(:plus_button) { "a[aria-label='イベント作成']" }

    describe "フッターナビ(スマホレイアウト)" do
      before do
        page.current_window.resize_to(375, 667)
      end

      context "ログイン済みの場合" do
        before do
          login(user)
        end

        it "スマホ用のタブバーが表示されていること" do
          expect(page).to have_content("ダッシュボード")
          expect(page).to have_css(plus_button)
          expect(page).to have_content("設定")
        end

        it "PC用のフッターが表示されていないこと" do
          expect(page).to have_no_content("© 2026 Schere")
        end

        context "左ホームアイコンを押す" do
          it "ルートページに遷移すること" do
            click_on "ダッシュボード"
            expect(page).to have_current_path(root_path)
          end
        end

        context "右設定アイコンを押す" do
          it "アカウント編集ページに遷移すること" do
            click_on "設定"
            expect(page).to have_current_path(edit_user_registration_path)
          end
        end

        context "中央＋ボタンを押す" do
          context "グループが存在する場合" do
            let!(:group) { create(:group, user: user) }
            let!(:other_group) { create(:group) }

            before do
              find(plus_button).click
            end

            it "イベントを作成するグループを選択するモーダルが開くこと" do
              expect(page).to have_content("どのグループのイベントを作成しますか？")
              expect(page).to have_content(group.name)
            end

            it "自分のグループのみ表示されること" do
              expect(page).to have_content(group.name)
              expect(page).to have_no_content(other_group.name)
            end

            it "選択したグループのイベント作成ページに遷移すること" do
              click_on group.name
              expect(page).to have_content("イベント作成")
              expect(page).to have_current_path(new_group_event_path(group))
            end
          end

          context "グループがまだ存在しない場合" do
            before do
              find(plus_button).click
            end

            it "グループ作成を促すモーダルが開くこと" do
              expect(page).to have_content("グループがまだありません")
              expect(page).to have_content("グループ作成へ")
            end

            it "グループ作成画面に遷移できること" do
              click_on "グループ作成へ"
              expect(page).to have_content("グループを作成する")
              expect(page).to have_current_path(new_group_path)
            end
          end
        end
      end

      context "ゲスト入室の場合" do
        let(:group) { create(:group) }
        before do
          visit new_group_join_path(group.join_token)
          fill_in "ゲスト名", with: "テストゲスト"
          click_on "参加する"
          expect(page).to have_content(group.name)
        end

        it "スマホ用のタブバーが表示されないこと" do
          expect(page).to have_no_content("ダッシュボード")
          expect(page).to have_no_css(plus_button)
          expect(page).to have_no_content("設定")
        end
      end
    end

    describe "フッター(PCレイアウト)" do
      before do
        page.current_window.resize_to(1680, 1050)
        login(user)
      end

      it "PC用のフッターが表示されていること" do
        expect(page).to have_content("© 2026 Schere")
      end

      it "スマホ用のタブバーが表示されていないこと" do
        expect(page).to have_no_content("ダッシュボード")
        expect(page).to have_no_css(plus_button)
        expect(page).to have_no_content("設定")
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
  end
end

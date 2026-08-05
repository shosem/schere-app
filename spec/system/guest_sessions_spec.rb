require 'rails_helper'

RSpec.describe "GuestSessions", type: :system do
  include LoginMacros
  describe "ゲスト入室機能" do
    let(:group) { create(:group) }
    before do
      visit new_group_join_path(group.join_token)
    end

    context "入室可能" do
      it "ゲスト入室ページからグループに参加できること" do
        fill_in "ゲスト名", with: "テストゲスト"
        click_on "参加する"
        expect(page).to have_current_path(group_path(group))
        expect(page).to have_content("#{group.name}にテストゲストさんとして入室しました")
        expect(Guest.count).to eq 1
      end

      it "ゲストログイン後、同一セッションであればグループ詳細画面に遷移すること" do
        fill_in "ゲスト名", with: "テストゲスト"
        click_on "参加する"
        expect(page).to have_content("#{group.name}にテストゲストさんとして入室しました")
        visit new_group_join_path(group.join_token)
        expect(page).to have_current_path(group_path(group))
      end
    end

    context "入室不可" do
      it "名前が空欄の場合グループに参加できないこと" do
        fill_in "ゲスト名", with: ""
        click_on "参加する"
        expect(page).to have_current_path(new_group_join_path(group.join_token))
        expect(page).to have_content("入室できませんでした")
        expect(page).to have_content("ゲスト名を入力してください")
        expect(Guest.count).to eq 0
      end
    end

    context "すでに入室したことのあるゲスト名で入室しようとしたとき" do
      let!(:guest) { create(:guest, name: "ゲストくん", group: group) }
      before do
        fill_in "ゲスト名", with: "ゲストくん"
        click_on "参加する"
      end

      it "確認用のモーダルが開くこと" do
        expect(page).to have_content("このグループには既に#{ guest.name }さんがいます。")
        expect(page).to have_button("本人です")
        expect(page).to have_button("違う名前にする")
      end

      it "本人の場合そのまま入室できること" do
        click_on "本人です"
        expect(page).to have_content("#{group.name}に#{guest.name}さんとして入室しました")
        expect(Guest.count).to eq 1
      end

      it "違う名前にするを選択するとモーダルが閉じること" do
        click_on "違う名前にする"
        expect(page).to have_no_content("このグループには既に#{ guest.name }さんがいます。")
        expect(page).to have_current_path(new_group_join_path(group.join_token))
      end
    end

    describe "アクセス制御" do
      it "グループ入室後、違うグループの詳細画面にアクセスできず、元のグループ詳細ページに戻ること" do
        other_group = create(:group)
        fill_in "ゲスト名", with: "テストゲスト"
        click_on "参加する"
        expect(page).to have_content("#{group.name}にテストゲストさんとして入室しました")
        visit group_path(other_group)
        expect(page).to have_current_path(group_path(group))
        expect(page).to have_content("グループにアクセスする権限がありません")
      end
    end
  end
describe "イベント共有リンクからの入室" do
      let(:group) { create(:group) }
      let!(:event) { create(:event, group: group) }

      context "まだ入室していないゲストの場合" do
        before do
          visit new_group_join_path(group.join_token, event_id: event.id)
        end

        it "名前を入力するとイベント詳細画面に着地すること" do
          fill_in "ゲスト名", with: "テストゲスト"
          click_on "参加する"
          expect(page).to have_current_path(group_event_path(group, event))
          expect(page).to have_content(event.title)
        end

        it "確認モーダルの「本人です」を経由してもイベント詳細画面に着地すること" do
          create(:guest, name: "ゲストくん", group: group)
          fill_in "ゲスト名", with: "ゲストくん"
          click_on "参加する"
          click_on "本人です"
          expect(page).to have_current_path(group_event_path(group, event))
        end
      end

      context "すでに入室しているゲストの場合" do
        it "名前の入力なしでイベント詳細画面に遷移すること" do
          visit new_group_join_path(group.join_token)
          fill_in "ゲスト名", with: "テストゲスト"
          click_on "参加する"
          expect(page).to have_content("入室しました")
          visit new_group_join_path(group.join_token, event_id: event.id)
          expect(page).to have_current_path(group_event_path(group, event))
          expect(Guest.count).to eq 1
        end
      end

      context "ログイン済みユーザーの場合" do
        it "ゲストを作らずにイベント詳細画面に遷移すること" do
          login(group.user)
          visit new_group_join_path(group.join_token, event_id: event.id)
          expect(page).to have_current_path(group_event_path(group, event))
          expect(Guest.count).to eq 0
        end
      end

      context "不正なevent_idを渡された場合" do
        it "存在しないidのときはグループ詳細画面に着地すること" do
          visit new_group_join_path(group.join_token, event_id: 0)
          fill_in "ゲスト名", with: "テストゲスト"
          click_on "参加する"
          expect(page).to have_current_path(group_path(group))
        end

        it "他グループのイベントidのときはグループ詳細画面に着地すること" do
          other_event = create(:event)
          visit new_group_join_path(group.join_token, event_id: other_event.id)
          fill_in "ゲスト名", with: "テストゲスト"
          click_on "参加する"
          expect(page).to have_current_path(group_path(group))
        end
      end
    end
end

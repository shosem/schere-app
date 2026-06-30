require 'rails_helper'

RSpec.describe "GuestSessions", type: :system do
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

      it "同じ名前で入室してもゲストが重複作成されないこと" do
        fill_in "ゲスト名", with: "テストゲスト"
        click_on "参加する"
        expect(page).to have_content("#{group.name}にテストゲストさんとして入室しました")
        visit new_group_join_path(group.join_token)
        fill_in "ゲスト名", with: "テストゲスト"
        click_on "参加する"
        expect(Guest.count).to eq 1
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
end

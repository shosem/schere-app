require 'rails_helper'

RSpec.describe "Groups", type: :system do
  include LoginMacros
  let(:user) { create(:user) }
  before do
    login(user)
  end

  describe "作成機能(new create)" do
    before do
      visit new_group_path
    end

    context "作成可能" do
      it "正しくグループが作成できること" do
        fill_in "グループ名", with: "グループ1"
        click_on "作成"
        expect(page).to have_current_path(root_path)
        expect(page).to have_content("グループを作成しました")
        expect(page).to have_content("グループ1")
      end
    end

    context "作成不可" do
      it "名前が空白のままだと作成できないこと" do
        click_on "作成"
        expect(page).to have_current_path(new_group_path)
        expect(page).to have_content("グループを作成できませんでした")
        expect(Group.count).to eq(0)
      end
    end
  end

  describe "一覧表示(index)" do
    it "自分のグループが0件のとき、グループが無い旨を表示する" do
      visit root_path
      expect(page).to have_content("まだグループはありません")
    end

    it "自分のグループが1件以上あるとき、グループ一覧が表示される" do
      first_group = create(:group, user: user)
      second_group = create(:group, user: user)
      visit root_path
      expect(page).to have_content(first_group.name)
      expect(page).to have_content(second_group.name)
    end

    it "他人のグループが見えないこと" do
      other_user = create(:user)
      other_group = create(:group, user: other_user)
      visit root_path
      expect(page).not_to have_content(other_group.name)
    end
  end

  describe "詳細(show)" do
    it "一覧画面から該当グループの詳細画面に遷移できること" do
      create(:group, user: user)
      other_group = create(:group, user: user)
      visit groups_path
      click_on other_group.name
      expect(page).to have_current_path(group_path(other_group))
      expect(page).to have_content(other_group.name)
    end
  end

  describe "削除機能(destroy)" do
    it "削除ボタンからグループを削除できること" do
      group = create(:group, user: user)
      other_group = create(:group, user: user)
      visit group_path(group)
      page.accept_confirm do
        click_on "グループを削除"
      end
      expect(page).to have_current_path(root_path)
      expect(page).to have_no_content(group.name)
      expect(page).to have_content(other_group.name)
    end
  end
end

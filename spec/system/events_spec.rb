require 'rails_helper'

RSpec.describe "Events", type: :system do
  include LoginMacros
  let(:user) { create(:user) }
  let(:group) { create(:group, user: user) }
  before do
    login(user)
  end

  describe "作成機能" do
    context "作成可能" do
      date = Date.tomorrow.to_s
      it "タイトル入力、候補日選択でイベントを作成できること" do
        visit new_group_event_path(group)
        fill_in "タイトル", with: "テストタイトル"
        find("[data-date='#{date}']").click
        click_on "作成"
        expect(page).to have_current_path(group_path(group))
        expect(page).to have_content("イベントを作成しました")
        expect(Event.count).to eq(1)
        expect(CandidateDate.count).to eq(1)
      end
    end

    context "作成不可" do
      it "候補日なしだと作成できないこと" do
        visit new_group_event_path(group)
        fill_in "タイトル", with: "テストタイトル"
        click_on "作成"
        expect(page).to have_current_path(new_group_event_path(group))
        expect(page).to have_content("イベントを作成できませんでした")
        expect(Event.count).to eq(0)
        expect(CandidateDate.count).to eq(0)
      end
    end
  end
end

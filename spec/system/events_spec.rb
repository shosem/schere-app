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

  describe "投票機能" do
    let(:event) { create(:event, group: group, candidate_dates_count: 3) }
    before do
      visit group_event_path(group, event)
    end
    context "投票可能" do
      it "投票できること" do
        event.candidate_dates.each do |c|
           choose("votes_#{c.id}_available", allow_label_click: true)
        end
        click_on "送信する"
        expect(page).to have_current_path(group_event_path(group, event))
        expect(page).to have_content("投票しました")
        expect(Vote.count).to eq 3
        expect(page).to have_content("回答済み：1人")
        within("[data-testid='answer-status']") do
          event.candidate_dates.each do |c|
            expect(page).to have_css("[data-testid='#{c.id}']", text: "1")
          end
        end
      end
    end
  end

  describe "日程確定機能" do
    let(:event) { create(:event, group: group, candidate_dates_count: 3) }
    before do
      visit group_event_path(group, event)
    end

    it "候補日の中から日程を確定できること" do
      c = event.candidate_dates.last
      page.accept_confirm do
        find("[data-testid='confirm-#{c.id}']").click
      end
      expect(page).to have_content("日程を確定しました")
      event.reload
      expect(event).to be_confirmed
      expect(event.confirmed_candidate_date_id).to eq c.id
      expect(page).to have_content("確定済み")
    end
  end
end

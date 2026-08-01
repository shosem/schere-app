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

    context "確定済みのイベント詳細画面で調整中に戻すボタンを押したとき" do
      before do
        c = event.candidate_dates.last
        page.accept_confirm do
          find("[data-testid='confirm-#{c.id}']").click
        end
      end
      it "調整中になり、確定の候補日IDがなくなること" do
        expect(page).to have_content("確定済み")
        page.accept_confirm do
          click_on "調整中に戻す"
        end
        expect(page).to have_content("調整中")
        event.reload
        expect(event).to be_adjusting
        expect(event.confirmed_candidate_date_id).to eq nil
        expect(page).to have_content("調整中")
      end
    end
  end

  describe "ステータスによる詳細画面の出し分け" do
    context "調整中の場合" do
      let(:event) { create(:event, group: group, candidate_dates_count: 3, status: "adjusting") }
      before do
        visit group_event_path(group, event)
      end
      it "投票フォーム、日程確定ボタンが表示され、確定された日程のバナーは表示されないこと" do
        expect(page).to have_content("調整中")
        expect(page).to have_content("回答状況")
        expect(page).to have_content("日程を確定する")
        expect(page).to have_no_content("確定日程")
      end
    end

    context "確定済みの場合" do
      let(:event) { create(:event, group: group, candidate_dates_count: 3, status: "confirmed") }
      before do
        event.update(confirmed_candidate_date_id: event.candidate_dates.last.id)
        visit group_event_path(group, event)
      end
      it "確定日程バナー、予約情報が表示され、投票フォーム、日程確定ボタンは表示されないこと" do
        expect(page).to have_current_path(group_event_path(group, event))
        expect(page).to have_content("確定済み")
        expect(page).to have_content("施設情報")
        expect(page).to have_content("確定日程")
        expect(page).to have_no_content("回答状況")
        expect(page).to have_no_content("日程を確定する")
      end

      it "予約済みの施設情報が正常に表示されること" do
        create(:venue, event: event,  name: "居酒屋テスト", price: 3000, reserved: true)
        visit group_event_path(group, event)
        expect(page).to have_content("居酒屋テスト")
        expect(page).to have_content("予約済み")
        expect(page).to have_content("3,000")
      end

      it "未予約の施設情報が正常に表示されること" do
        create(:venue, event: event,  name: "カフェテスト", reserved: false)
        visit group_event_path(group, event)
        expect(page).to have_content("カフェテスト")
        expect(page).to have_content("未予約")
      end

      it "集計結果が正しく表示されること" do
        create(:guest_vote, candidate_date: event.candidate_dates.last, answer: "available")
        visit group_event_path(group, event)
        expect(page).to have_content("集計結果")
        within("[data-testid='available']") do
          expect(page).to have_content("1")
        end
      end
    end
  end
  describe "施設情報機能" do
    let(:event) { create(:event, group: group, candidate_dates_count: 3, status: "confirmed") }
      before do
        event.update(confirmed_candidate_date_id: event.candidate_dates.last.id)
        visit group_event_path(group, event)
      end

    context "グループ作成者のアカウントでログインしている場合" do
      it "施設情報の作成ができること" do
        expect(page).to have_content("＋追加")
        click_on "＋追加"
        fill_in "施設名", with: "スポーツセンター"
        click_on "登録"
        expect(page).to have_content("スポーツセンター")
        within("[id='venue_#{event.venues.last.id}']") do
          expect(page).to have_content("スポーツセンター")
        end
        expect(event.venues.count).to eq 1
      end

      it "施設情報の編集ができること" do
        venue = create(:venue, event: event)
        visit current_path
        within("[id='venue_#{venue.id}']") do
          click_on "編集"
        end
        fill_in "施設名", with: "変更テストセンター"
        check('venue[reserved]', allow_label_click: true)
        click_on "保存"
        expect(page).to have_content("変更テストセンター")
        expect(page).to have_content("予約済み")
      end

      it "施設情報の削除ができること" do
        venue = create(:venue, event: event)
        visit current_path
        within("[id='venue_#{venue.id}']") do
          page.accept_confirm do
            click_on "削除"
          end
        end
        expect(page).to have_no_content(venue.name)
        expect(event.venues.count).to eq 0
      end
    end

    context "ゲストでログインしている場合" do
      let!(:venue) { create(:venue, event: event) }

      it "施設情報の作成・編集・削除ボタンが表示されないこと" do
        click_button(user.name.first)
        click_on("ログアウト")
        expect(page).to have_content("ログアウトしました")
        visit new_group_join_path(group.join_token)
        fill_in "ゲスト名", with: "テストゲスト"
        click_on "参加する"
        expect(page).to have_current_path(group_path(group))
        visit group_event_path(group, event)
        expect(page).to have_no_content("＋追加")
        expect(page).to have_no_content("編集")
        expect(page).to have_no_content("削除")
      end
    end
  end
end

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
      # 候補日のため未来が好ましいが、カレンダー（ブラウザ）は当月を描画するため、月末にテストを行うと落ちる。そのため当日にした
      # アプリ内ではDate.currentを使用するよう統一しているが、
      # Date.currentはRailsのTZを追いかける。ブラウザはそれを見ない。
      # だからRailsのTZを変えた瞬間にズレる。Date.today はブラウザと同じくコンテナのOSのTZを見るので揃ったままになる
      let(:date) { Date.today }
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

  describe "編集機能" do
    let(:event) { create(:event, group: group) }
    before do
      visit group_event_path(group, event)
    end
    context "編集可能" do
      it "イベントを編集できること" do
        click_on "編集"
        fill_in "タイトル", with: "テストイベントだよ"
        click_on "保存"
        expect(page).to have_content("編集内容を保存しました")
        expect(page).to have_content("テストイベントだよ")
        expect(Event.count).to eq 1
      end
    end

    context "編集不可" do
      it "ゲスト入室の場合編集ボタンが表示されないこと" do
        click_button(user.name.first)
        click_on("ログアウト")
        expect(page).to have_content("ログアウトしました")
        visit new_group_join_path(group.join_token)
        fill_in "ゲスト名", with: "ゲスト"
        click_on "参加する"
        expect(page).to have_content("入室しました")
        visit group_event_path(group, event)
        expect(page).to have_no_link("編集")
      end
    end
  end

  describe "削除機能" do
    let(:event) { create(:event, group: group) }
    before do
      visit group_event_path(group, event)
    end
    context "削除可能" do
      it "イベントを削除できること" do
        page.accept_confirm do
          click_on "削除"
        end
        expect(page).to have_content("イベントを削除しました")
        expect(Event.count).to eq 0
      end
    end

    context "削除不可" do
      it "ゲスト入室の場合削除ボタンが表示されないこと" do
        click_button(user.name.first)
        click_on("ログアウト")
        expect(page).to have_content("ログアウトしました")
        visit new_group_join_path(group.join_token)
        fill_in "ゲスト名", with: "ゲスト"
        click_on "参加する"
        expect(page).to have_content("入室しました")
        visit group_event_path(group, event)
        expect(page).to have_no_link("削除")
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

      it "編集画面にてカレンダーUIが表示されないこと" do
        visit edit_group_event_path(group, event)
        expect(page).to have_no_css("[data-testid='calendar-card']")
      end
    end
  end

  describe "共有ボタン" do
    let(:event) { create(:event, group: group) }
    before do
      visit group_event_path(group, event)
    end

    it "event_idを含む入室用urlが、erbからstimulusへ渡されていること" do
      element = find("[data-controller='share']")
      expect(element["data-share-url-value"]).to end_with(new_group_join_path(group.join_token, event_id: event.id))
    end

    it "共有する文言にイベント名が含まれていること" do
      element = find("[data-controller='share']")
      expect(element["data-share-text-value"]).to include(event.title)
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

  describe "選択した候補日のフォーム表示" do
    let(:date) { Date.today }
    context "作成失敗時" do
      before do
        visit new_group_event_path(group)
        find("[data-date='#{date}']").click
        click_on "作成"
        expect(page).to have_content("イベントを作成できませんでした")
      end

      it "選択していた候補日がerbからstimulusへ渡されていること" do
        element = find("[data-controller='calendar']")
        expect(element["data-calendar-selected-value"]).to include(date.to_s)
      end

      it "選択していた候補日が、選択済みリストに残っていること" do
        within("[data-calendar-target='selectedList']") do
          expect(page).to have_css("[data-date='#{date}']")
        end
      end
    end

    context "更新失敗時" do
      let!(:event) { create(:event, group: group, candidate_dates_count: 1) }
      before do
        event.candidate_dates.first.update!(date: Date.today + 3)
        visit edit_group_event_path(group, event)
        fill_in "タイトル", with: ""
        find("[data-date='#{date}']").click
        click_on "保存"
        expect(page).to have_content("編集内容を保存できませんでした")
      end
      it "選択していた候補日と既存の候補日が、選択済みリストに残っていること" do
        cd = event.candidate_dates.first
        within("[data-calendar-target='selectedList']") do
          expect(page).to have_css("[data-date='#{date}']")
          expect(page).to have_css("[data-date='#{cd.date}']")
        end
      end

      it "選択していた候補日がerbからstimulusへ渡されていること" do
        cd = event.candidate_dates.first
        element = find("[data-controller='calendar']")
        expect(element["data-calendar-selected-value"]).to include(date.to_s)
        expect(element["data-calendar-selected-value"]).to include(cd.date.to_s)
      end
    end
  end
end

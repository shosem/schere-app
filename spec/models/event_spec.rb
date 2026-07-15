require 'rails_helper'

RSpec.describe Event, type: :model do
  context "作成可能" do
    it "候補日を持ったイベントを正常に作成できること" do
      event = build(:event)
      expect(event).to be_valid
    end
  end

  context "作成不可" do
    it "タイトルが空白の場合作成できないこと" do
      event = build(:event, title: "")
      expect(event).to be_invalid
      expect(event.errors[:title]).to be_present
    end

    it "候補日を設定しない場合イベントを作成できないこと" do
      event = build(:event, candidate_dates_count: 0)
      expect(event).to be_invalid
      expect(event.errors[:candidate_dates]).to be_present
    end
  end
end

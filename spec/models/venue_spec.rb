require 'rails_helper'

RSpec.describe Venue, type: :model do
  context "作成可能" do
    it "予約情報を作成できること" do
      venue = build(:venue)
      expect(venue).to be_valid
    end
  end

  context "作成不可" do
    it "施設名nameが空白の場合バリデーションエラーが起き作成できないこと" do
      venue = build(:venue, name: "")
      expect(venue).to be_invalid
      expect(venue.errors[:name]).to be_present
    end

    it "予算priceが負の数字が入るとエラーが起き作成できないこと" do
      venue = build(:venue, price: -1)
      expect(venue).to be_invalid
      expect(venue.errors[:price]).to be_present
    end

    it "備考noteが10_000文字を超えるとエラーが起き作成できないこと" do
      venue = build(:venue, note: "a" * 10_001)
      expect(venue).to be_invalid
      expect(venue.errors[:note]).to be_present
    end

    it "eventと紐づいていないと作成できないこと" do
      venue = build(:venue, event: nil)
      expect(venue).to be_invalid
    end
  end
end

require 'rails_helper'

RSpec.describe Guest, type: :model do
  context "作成可能" do
    it "名前が上限の10文字の場合作成できること" do
      guest = build(:guest, name: "このゲストは10文字")
      expect(guest).to be_valid
    end

    it "ゲスト作成時にsession_tokenが生成されること" do
      guest = create(:guest)
      expect(guest.session_token).to be_truthy
    end
  end

  context "作成不可" do
    it "名前が空欄の場合作成できないこと" do
      guest = build(:guest, name: "")
      expect(guest).to be_invalid
    end

    it "名前が11文字以上の場合作成できないこと" do
      guest = build(:guest, name: "このゲストは11文字だ")
      expect(guest).to be_invalid
    end
  end
end

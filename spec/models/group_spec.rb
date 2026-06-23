require 'rails_helper'

RSpec.describe Group, type: :model do
  context '作成可能' do
    it '有効なグループが作成できること' do
      group = create(:group)
      expect(group).to be_valid
      expect(group.join_token).to be_truthy
    end
  end
  context '作成失敗' do
    it '名前が空白の場合' do
      emp_group = build(:group, name: "")
      expect(emp_group).to be_invalid
    end
  end
end

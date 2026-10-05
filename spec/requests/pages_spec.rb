require 'rails_helper'

RSpec.describe "Pages", type: :request do
  # 静的3ページはログイン不要。ApplicationController に authenticate_user! が
  # 全体適用されると、登録前の人が規約・ポリシーを読めなくなる。
  # そのときに気付けるのはこのテストだけなので、未ログインで200を固定する。
  describe "未ログインの場合" do
    it "利用規約が表示されること" do
      get terms_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("準拠法・裁判管轄")
    end

    it "プライバシーポリシーが表示されること" do
      get privacy_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("取得する情報")
    end

    it "お問い合わせが表示されること" do
      get contact_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("お問い合わせいただける内容")
    end
  end
end

require 'rails_helper'

RSpec.describe "TopPages", type: :request do
  describe "トップページ" do
    it "トップページが表示されること" do
      get root_path
      expect(response).to have_http_status(200)
    end

    it "i18nが正しく動き、タイトルが日本語表記で表示されていること" do
      get root_path
      expect(response.body).to include('トップページ')
    end
  end
end

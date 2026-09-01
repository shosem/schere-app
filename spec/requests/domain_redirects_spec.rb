require 'rails_helper'

RSpec.describe "DomainRedirects", type: :request do
  let(:old_host) { "schere-app.onrender.com" }
  let(:new_host) { "schere.shosem.com" }

  describe "旧ドメインでアクセスした場合" do
    before { host! old_host }

    it "トップページが新ドメインへ301でリダイレクトされること" do
      get "/"
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("https://#{new_host}/")
    end

    it "パスが保持されること" do
      get "/groups/abc123/join"
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("https://#{new_host}/groups/abc123/join")
    end

    it "クエリパラメータが保持されること" do
      get "/groups/abc123/join", params: { event_id: 5 }
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("https://#{new_host}/groups/abc123/join?event_id=5")
    end

    it "存在しないパスでもリダイレクトされること" do
      get "/no/such/page"
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to("https://#{new_host}/no/such/page")
    end
  end

  describe "新ドメインでアクセスした場合" do
    before { host! new_host }

    it "リダイレクトされないこと" do
      get "/"
      expect(response).not_to have_http_status(:moved_permanently)
    end
  end
end

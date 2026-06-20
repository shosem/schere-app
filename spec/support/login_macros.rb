module LoginMacros
  def login(user)
    visit new_user_session_path
    fill_in 'Eメール', with: user.email
    fill_in 'パスワード', with: "pass"
    click_on 'ログイン'
    expect(page).to have_content("ログインしました。")
  end

  def only_login(user)
    visit new_user_session_path
    fill_in 'Eメール', with: user.email
    fill_in 'パスワード', with: "pass"
    click_on 'ログイン'
  end
end

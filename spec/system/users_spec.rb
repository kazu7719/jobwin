require 'rails_helper'
require 'securerandom'

RSpec.describe 'ユーザーログイン', type: :system do
  # Devise 4.9.4 が Rack の :unprocessable_entity ステータスに依存しているため、
  # 実行時に "Status code :unprocessable_entity is deprecated" という警告が出る。
  # 現在の挙動には影響しないためテスト結果には影響なし。
  before do
    # フルブラウザを利用した挙動確認のため、Selenium + Chrome ドライバを使用する
    driven_by(:selenium_chrome)
  end

  describe 'ログインしていない状態の場合' do
    it 'ログインしていない状態でプロジェクト一覧ページにアクセスした場合、サインインページに移動する' do
      # ## トップページに遷移する
      visit root_path

      expect(page).to have_current_path(root_path)

      # ## ログインしていない場合、サインインページに遷移していることを確認する
      visit projects_path

      expect(page).to have_current_path(new_user_session_path)
    end

    it 'ログインしていない状態でタスク一覧ページにアクセスした場合、サインインページに移動する' do
      # ## トップページに遷移する
      visit root_path

      expect(page).to have_current_path(root_path)

      # ## ログインしていない場合、サインインページに遷移していることを確認する
      visit tasks_path

      expect(page).to have_current_path(new_user_session_path)
    end

    it 'ログインしていない状態で習慣一覧ページにアクセスした場合、サインインページに移動する' do
      # ## トップページに遷移する
      visit root_path

      expect(page).to have_current_path(root_path)

      # ## ログインしていない場合、サインインページに遷移していることを確認する
      visit habits_path

      expect(page).to have_current_path(new_user_session_path)
    end
  end

  describe 'ログインができる場合' do
    let(:user) { create(:user, password: 'password', password_confirmation: 'password') }

    it '保存されているユーザーの情報と合致すればログインができる' do
      # ## トップページに移動する
      visit root_path

      expect(page).to have_current_path(root_path)

      # ## トップページにログインページへ遷移するボタンがあることを確認する
      expect(page).to have_link('ログイン', href: new_user_session_path)

      # ## ログインページへ遷移する
      click_link 'ログイン', href: new_user_session_path

      # Turbo の挙動などで遷移が完了しないケースに備えて直接アクセスも実施する
      visit new_user_session_path unless page.current_path == new_user_session_path

      expect(page).to have_current_path(new_user_session_path, ignore_query: true)

      # ## 正しいユーザー情報を入力する
      fill_in 'メールアドレス', with: user.email
      fill_in 'パスワード', with: 'password'

      # ## ログインボタンを押す
      click_button 'ログイン'

      # ## トップページへ遷移することを確認する
      expect(page).to have_current_path(root_path)

      # ## カーソルを合わせるとログアウトボタンが表示されることを確認する
      expect(page).to have_link('ログアウト', href: destroy_user_session_path)

      # ## サインアップページへ遷移するボタンやログインページへ遷移するボタンが表示されていないことを確認する
      expect(page).not_to have_link('新規登録', href: new_user_registration_path)
      expect(page).not_to have_link('ログイン', href: new_user_session_path)
    end
  end

  describe 'ログインができない場合' do
    let(:user) { create(:user) }

    it '保存されているユーザーの情報と合致しないとログインができない' do
      # ## トップページに移動する
      visit root_path

      expect(page).to have_current_path(root_path)

      # ## トップページにログインページへ遷移するボタンがあることを確認する
      expect(page).to have_link('ログイン', href: new_user_session_path)

      # ## ログインページへ遷移する
      click_link 'ログイン'

      expect(page).to have_current_path(new_user_session_path)

      # ## ユーザー情報を入力する
      fill_in 'メールアドレス', with: user.email
      fill_in 'パスワード', with: 'wrong-password'

      # ## ログインボタンを押す
      click_button 'ログイン'

      # ## 失敗時はサインインページへ戻され、ログインフォームが再表示されることを確認する
      expect(page).to have_current_path(new_user_session_path, ignore_query: true)
      expect(page).to have_button('ログイン')
    end
  end

  describe 'ユーザー新規登録ができるとき' do
    let(:signup_email) { "signup_#{SecureRandom.hex(8)}@example.com" }
    let(:signup_password) { 'password' }
    let(:labor_name) { Labor.find(2).name }

    it '正しい情報を入力すればユーザー新規登録ができてトップページに移動する' do
      # ## トップページに移動する
      visit root_path

      expect(page).to have_current_path(root_path)

      # ## トップページにサインアップページへ遷移するボタンがある
      expect(page).to have_link('新規登録', href: new_user_registration_path)

      # ## 新規登録ページへ移動する
      click_link '新規登録'

      expect(page).to have_current_path(new_user_registration_path)

      # ## ユーザー情報を入力する
      fill_in 'ニックネーム', with: 'テスト太郎'
      select labor_name, from: '身分'
      fill_in '目標', with: 'テスト目標'
      fill_in 'メールアドレス', with: signup_email
      fill_in 'パスワード', with: signup_password
      fill_in 'パスワード（確認）', with: signup_password

      # ## サインアップボタンを押すとユーザーモデルのカウントが1上がる
      expect {
        click_button '登録する'
        expect(page).to have_current_path(root_path, ignore_query: true)
      }.to change(User, :count).by(1)

      # ## トップページへ遷移することを確認する
      expect(page).to have_current_path(root_path)

      # ## カーソルを合わせるとログアウトボタンが表示される
      expect(page).to have_link('ログアウト', href: destroy_user_session_path)

      # ## サインアップページへ遷移するボタンや、ログインページへ遷移するボタンが表示されていない
      expect(page).not_to have_link('新規登録', href: new_user_registration_path)
      expect(page).not_to have_link('ログイン', href: new_user_session_path)
    end
  end

  describe 'ユーザー新規登録ができないとき' do
    it '誤った情報ではユーザー新規登録ができずに新規登録ページへ戻ってくる' do
      # ## トップページに移動する
      visit root_path

      expect(page).to have_current_path(root_path)

      # ## トップページにサインアップページへ遷移するボタンがある
      expect(page).to have_link('新規登録', href: new_user_registration_path)

      # ## 新規登録ページへ移動する
      click_link '新規登録'

      expect(page).to have_current_path(new_user_registration_path)

      # ## ユーザー情報を入力する
      fill_in 'ニックネーム', with: ''
      select '---', from: '身分'
      fill_in '目標', with: ''
      fill_in 'メールアドレス', with: 'invalid-email'
      fill_in 'パスワード', with: 'short'
      fill_in 'パスワード（確認）', with: 'different'

      # ## サインアップボタンを押してもユーザーモデルのカウントは上がらない
      expect {
        click_button '登録する'
      }.not_to change(User, :count)

      # ## 新規登録ページへ戻される
      expect(page).to have_current_path(new_user_registration_path)
    end
  end
end
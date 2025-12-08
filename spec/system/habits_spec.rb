require 'rails_helper'

RSpec.describe '習慣管理', type: :system do
  before do
    driven_by(:selenium_chrome)
  end

  def sign_in(user)
    visit root_path
    expect(page).to have_link('ログイン', href: new_user_session_path)

    click_link 'ログイン', href: new_user_session_path
    expect(page).to have_current_path(new_user_session_path)

    fill_in 'メールアドレス', with: user.email
    fill_in 'パスワード', with: user.password
    click_button 'ログイン'

    expect(page).to have_current_path(root_path)
  end

  describe 'A:習慣登録' do
    let(:user) { create(:user) }

    context '習慣登録ができる時' do
      it 'ログインしたユーザーは新規登録できる' do
        habit_name = '毎朝の読書'
        start_day = Date.current

        sign_in(user)

        # ## 一覧ページに移動する
        if page.has_link?('習慣を登録・確認', href: habits_path)
          click_link '習慣を登録・確認', href: habits_path
        else
          visit habits_path
        end
        expect(page).to have_current_path(habits_path)

        # ## 新規登録ページへのボタンがあることを確認する
        expect(page).to have_link('習慣を登録', href: new_habit_path)

        # ## 登録ページに移動する
        click_link '習慣を登録', href: new_habit_path
        expect(page).to have_current_path(new_habit_path)

        # ## フォームに情報を入力する
        fill_in '習慣名', with: habit_name
        fill_in '開始日', with: start_day

        # ## 送信するとhabitモデルのカウントが1上がることを確認する
        expect do
          click_button '習慣を登録'
          expect(page).to have_current_path(habits_path, ignore_query: true)
        end.to change(Habit, :count).by(1)

        # ## 送信した値がDBに保存されていることを確認する
        created_habit = Habit.order(created_at: :desc).first
        expect(created_habit.habit_name).to eq(habit_name)
        expect(created_habit.start_day.to_date).to eq(start_day)

        # ## 習慣一覧ページに遷移していることを確認する
        if page.has_link?('習慣を登録・確認', href: habits_path)
          click_link '習慣を登録・確認', href: habits_path
        else
          visit habits_path
        end
        expect(page).to have_current_path(habits_path)

        # ## 送信した値がカレンダーとともにブラウザに表示されていることを確認する
        expect(page).to have_content(habit_name)
        expect(page).to have_content(start_day.strftime('%m/%d'))
      end
    end

    context '習慣登録ができない時' do
      it 'ログインしていないと新規登録ページに遷移できない' do
        # ## トップページに移動する
        visit root_path
        expect(page).to have_current_path(root_path)

        # ## 一覧ページへのボタンを押すとログイン画面に遷移する
        click_link '習慣を登録・確認', href: habits_path
        expect(page).to have_current_path(new_user_session_path)
      end

      it '送る値が空のため、登録に失敗する' do
        sign_in(user)

        # ## 一覧ページに移動する
        if page.has_link?('習慣を登録・確認', href: habits_path)
          click_link '習慣を登録・確認', href: habits_path
        else
          visit habits_path
        end
        expect(page).to have_current_path(habits_path)

        # ## 新規登録ページへのボタンがあることを確認する
        expect(page).to have_link('習慣を登録', href: new_habit_path)

        # ## 新規登録ページへ遷移する
        click_link '習慣を登録', href: new_habit_path
        expect(page).to have_current_path(new_habit_path)

        # ## DBに保存されていないことを確認する
        expect do
          click_button '習慣を登録'
        end.not_to change(Habit, :count)

        # ## 新規登録ページに戻ってくることを確認する
        expect(page).to have_current_path(new_habit_path)
      end
    end
  end

  describe 'B:習慣編集' do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let!(:habit1) { create(:habit, user: owner, habit_name: '習慣1', start_day: Date.current) }
    let!(:habit2) { create(:habit, user: other_user) }

    context '習慣編集ができる時' do
      it 'ログインしたユーザーは自分が投稿した習慣の編集ができる' do
        updated_name = '編集後の習慣'
        updated_start_day = Date.current - 1.day

        sign_in(owner)

        # ## 一覧ページに移動する
        if page.has_link?('習慣を登録・確認', href: habits_path)
          click_link '習慣を登録・確認', href: habits_path
        else
          visit habits_path
        end
        expect(page).to have_current_path(habits_path)

        # ## 詳細ページに移動する
        click_link habit1.habit_name, href: habit_path(habit1)
        expect(page).to have_current_path(habit_path(habit1))

        # ## 習慣1の詳細ページに「編集」へのリンクがあることを確認する
        expect(page).to have_link('編集', href: edit_habit_path(habit1))

        # ## 習慣1に「編集」へのリンクがあることを確認する
        click_link '編集', href: edit_habit_path(habit1)

        # ## 編集ページへ遷移する
        expect(page).to have_current_path(edit_habit_path(habit1))

        # ## すでに登録済みの内容がフォームに入っていることを確認する
        expect(page).to have_field('習慣名', with: habit1.habit_name)
        expect(page).to have_field('開始日', with: habit1.start_day.to_date)

        # ## 登録内容を編集する
        fill_in '習慣名', with: updated_name
        fill_in '開始日', with: updated_start_day

        # ## 編集してもhabitモデルのカウントは変わらないことを確認する
        expect do
          click_button '習慣を更新'
          expect(page).to have_current_path(habits_path, ignore_query: true)
        end.not_to change(Habit, :count)

        # ## 一覧ページに編集した内容が存在することを確認する
        expect(page).to have_content(updated_name)
        expect(page).to have_content(updated_start_day.strftime('%m/%d'))

        # ## 詳細ページに編集した内容が存在することを確認する
        click_link updated_name, href: habit_path(habit1)
        expect(page).to have_current_path(habit_path(habit1))
        expect(page).to have_content(updated_name)
        expect(page).to have_content(updated_start_day.strftime('%Y/%m/%d'))
      end
    end

    context '習慣編集ができない時' do
      it 'ログインしたユーザーは自分以外が登録した習慣の編集画面には遷移できない' do
        sign_in(owner)

        visit edit_habit_path(habit2)
        expect(page).to have_current_path(root_path)
      end

      it 'ログインしていないと習慣の編集画面には遷移できない' do
        # ## トップページにいる
        visit root_path
        expect(page).to have_current_path(root_path)

        # ## 一覧ページへのボタンを押すとログイン画面に遷移する
        click_link '習慣を登録・確認', href: habits_path
        expect(page).to have_current_path(new_user_session_path)
      end

      it '送る値が空のため、編集に失敗する' do
        sign_in(owner)

        # ## 一覧ページに移動する
        if page.has_link?('習慣を登録・確認', href: habits_path)
          click_link '習慣を登録・確認', href: habits_path
        else
          visit habits_path
        end
        expect(page).to have_current_path(habits_path)

        # ## 詳細ページに移動する
        click_link habit1.habit_name, href: habit_path(habit1)
        expect(page).to have_current_path(habit_path(habit1))

        # ## 習慣1の詳細ページに「編集」へのリンクがあることを確認する
        expect(page).to have_link('編集', href: edit_habit_path(habit1))

        # ## 編集ページへ遷移する
        click_link '編集', href: edit_habit_path(habit1)
        expect(page).to have_current_path(edit_habit_path(habit1))

        # ## すでに登録済みの内容がフォームに入っていることを確認する
        expect(page).to have_field('習慣名', with: habit1.habit_name)

        # ## 登録内容を編集し、空の状態にする
        fill_in '習慣名', with: ''
        fill_in '開始日', with: ''

        # ## DBは変わってないことを確認する
        expect do
          click_button '習慣を更新'
        end.not_to change(Habit, :count)

        # ## 編集ページに戻ってくることを確認する
        expect(page).to have_current_path(edit_habit_path(habit1))
      end
    end
  end

  describe 'C:習慣削除' do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let!(:habit1) { create(:habit, user: owner, habit_name: '削除する習慣') }
    let!(:habit2) { create(:habit, user: other_user) }

    context '習慣削除ができる時' do
      it 'ログインしたユーザーは自らが登録した習慣の削除ができる' do
        sign_in(owner)

        # ## 一覧ページに移動する
        click_link '習慣を登録・確認', href: habits_path
        expect(page).to have_current_path(habits_path)

        # ## 詳細ページに移動する
        click_link habit1.habit_name, href: habit_path(habit1)
        expect(page).to have_current_path(habit_path(habit1))

        # ## 習慣1の詳細ページに「削除」へのリンクがあることを確認する
        expect(page).to have_button('削除')

        # ## 登録を削除するとレコードの数が1減ることを確認する
        expect do
          click_button '削除'
          expect(page).to have_current_path(habits_path, ignore_query: true)
        end.to change(Habit, :count).by(-1)

        # ## 一覧ページにはタスク1が存在しないことを確認する
        expect(page).not_to have_content(habit1.habit_name)
      end
    end

    context '習慣削除ができない時' do
      it 'ログインしたユーザーは自分以外が登録した習慣の削除ができない' do
        sign_in(owner)

        visit habit_path(habit2)
        expect(page).to have_current_path(root_path)
      end

      it 'ログインしていないと習慣の削除ボタンがないことを確認する' do
        # ## トップページに移動する
        visit root_path
        expect(page).to have_current_path(root_path)

        # ## 一覧ページへのボタンを押すとログイン画面に遷移する
        click_link '習慣を登録・確認', href: habits_path
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end

  describe 'D:習慣詳細表示' do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let!(:habit1) { create(:habit, user: owner, habit_name: '習慣詳細', start_day: Date.current) }
    let!(:habit2) { create(:habit, user: other_user) }

    context '習慣詳細表示できる時' do
      it 'ログインしたユーザーは自分が登録した習慣詳細ページに遷移してタスク内容が表示される' do
        sign_in(owner)

        # ## 一覧ページに移動する
        click_link '習慣を登録・確認', href: habits_path
        expect(page).to have_current_path(habits_path)

        # ## 詳細ページに移動する
        click_link habit1.habit_name, href: habit_path(habit1)
        expect(page).to have_current_path(habit_path(habit1))

        # ## 詳細ページに習慣の詳細が含まれている
        expect(page).to have_content(habit1.habit_name)
        expect(page).to have_content(habit1.start_day.strftime('%Y/%m/%d'))
      end
    end

    context '習慣詳細表示ができない時' do
      it 'ログインしたユーザーは自分以外が登録した習慣の詳細表示ができない' do
        sign_in(owner)

        visit habit_path(habit2)
        expect(page).to have_current_path(root_path)
      end

      it 'ログインしていない状態でツイート詳細ページに遷移できない' do
        # ## トップページに移動する
        visit root_path
        expect(page).to have_current_path(root_path)

        # ## 一覧ページへのボタンを押すとログイン画面に遷移する
        click_link '習慣を登録・確認', href: habits_path
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end
end
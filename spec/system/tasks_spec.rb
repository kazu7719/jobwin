require 'rails_helper'

RSpec.describe 'タスク管理', type: :system do
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

  describe 'A:タスク登録' do
    let(:user) { create(:user) }

    context 'タスク登録ができる時' do
      it 'ログインしたユーザーは新規登録できる' do
        task_name = '新しいタスク'
        start_day = Date.current
        schedule_end_day = Date.current + 3.days
        end_day = Date.current + 5.days
        memo = 'タスクのメモ'

        sign_in(user)

        # ## 一覧ページに移動する
        if page.has_link?('タスクを登録・確認', href: tasks_path)
          click_link 'タスクを登録・確認', href: tasks_path
        else
          visit tasks_path
        end
        expect(page).to have_current_path(tasks_path)

        # ## 新規登録ページへのボタンがあることを確認する
        expect(page).to have_link('タスク新規登録', href: new_task_path)

        # ## 登録ページに移動する
        click_link 'タスク新規登録', href: new_task_path
        expect(page).to have_current_path(new_task_path)

        # ## フォームに情報を入力する
        fill_in 'タスク名', with: task_name
        fill_in '開始日', with: start_day
        fill_in '終了予定日', with: schedule_end_day
        fill_in '終了日', with: end_day
        fill_in 'メモ', with: memo

        # ## 送信するとtaskモデルのカウントが1上がることを確認する
        expect do
          click_button 'タスクを登録'
          expect(page).to have_current_path(tasks_path, ignore_query: true)
        end.to change(Task, :count).by(1)

        # ## 送信した値がDBに保存されていることを確認する
        created_task = Task.order(created_at: :desc).first
        expect(created_task.task_name).to eq(task_name)
        expect(created_task.start_day.to_date).to eq(start_day)
        expect(created_task.schedule_end_day.to_date).to eq(schedule_end_day)
        expect(created_task.end_day.to_date).to eq(end_day)
        expect(created_task.memo).to eq(memo)

        # ## タスク一覧ページに遷移していることを確認する
        if page.has_link?('タスクを登録・確認', href: tasks_path)
          click_link 'タスクを登録・確認', href: tasks_path
        else
          visit tasks_path
        end
        expect(page).to have_current_path(tasks_path)

        # ## 送信した値がブラウザに表示されていることを確認する
        expect(page).to have_content(task_name)
        expect(page).to have_content(start_day.strftime('%Y/%m/%d'))
        expect(page).to have_content(schedule_end_day.strftime('%Y/%m/%d'))
      end
    end

    context 'タスク登録ができない時' do
      it 'ログインしていないと新規登録ページに遷移できない' do
        # ## トップページに移動する
        visit root_path
        expect(page).to have_current_path(root_path)

        # ## 一覧ページへのボタンを押すとログイン画面に遷移する
        click_link 'タスクを登録・確認', href: tasks_path
        expect(page).to have_current_path(new_user_session_path)
      end

      it '送る値が空のため、登録に失敗する' do
        sign_in(user)

        # ## 一覧ページに移動する
        if page.has_link?('タスクを登録・確認', href: tasks_path)
          click_link 'タスクを登録・確認', href: tasks_path
        else
          visit tasks_path
        end
        expect(page).to have_current_path(tasks_path)

        # ## 新規登録ページへのボタンがあることを確認する
        expect(page).to have_link('タスク新規登録', href: new_task_path)

        # ## 新規登録ページへ遷移する
        click_link 'タスク新規登録', href: new_task_path
        expect(page).to have_current_path(new_task_path)

        # ## DBに保存されていないことを確認する
        expect do
          click_button 'タスクを登録'
        end.not_to change(Task, :count)

        # ## 新規登録ページに戻ってくることを確認する
        expect(page).to have_current_path(new_task_path)
      end
    end
  end

  describe 'B:タスク編集' do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let!(:task1) do
      create(
        :task,
        user: owner,
        task_name: 'タスク1',
        start_day: Date.current,
        schedule_end_day: Date.current + 2.days,
        end_day: Date.current + 3.days,
        memo: '元のタスクメモ'
      )
    end
    let!(:task2) { create(:task, user: other_user) }

    context 'タスク編集ができる時' do
      it 'ログインしたユーザーは自分が投稿したタスクの編集ができる' do
        updated_name = '編集後のタスク'
        updated_start_day = Date.current + 1.day
        updated_schedule_end_day = Date.current + 4.days
        updated_end_day = Date.current + 5.days
        updated_memo = '編集後のメモ'

        sign_in(owner)

        # ## 一覧ページに移動する
        if page.has_link?('タスクを登録・確認', href: tasks_path)
          click_link 'タスクを登録・確認', href: tasks_path
        else
          visit tasks_path
        end
        expect(page).to have_current_path(tasks_path)

        # ## 詳細ページに移動する
        click_link task1.task_name, href: task_path(task1)
        expect(page).to have_current_path(task_path(task1))

        # ## タスク1の詳細ページに「編集」へのリンクがあることを確認する
        expect(page).to have_link('編集', href: edit_task_path(task1))

        # ## タスク1に「編集」へのリンクがあることを確認する
        click_link '編集', href: edit_task_path(task1)

        # ## 編集ページへ遷移する
        expect(page).to have_current_path(edit_task_path(task1))

        # ## すでに登録済みの内容がフォームに入っていることを確認する
        expect(page).to have_field('タスク名', with: task1.task_name)
        expect(page).to have_field('メモ', with: task1.memo)

        # ## 登録内容を編集する
        fill_in 'タスク名', with: updated_name
        fill_in '開始日', with: updated_start_day
        fill_in '終了予定日', with: updated_schedule_end_day
        fill_in '終了日', with: updated_end_day
        fill_in 'メモ', with: updated_memo

        # ## 編集してもtaskモデルのカウントは変わらないことを確認する
        expect do
          click_button 'タスクを更新'
          expect(page).to have_current_path(tasks_path, ignore_query: true)
        end.not_to change(Task, :count)

        # ## 一覧ページに編集した内容が存在することを確認する
        expect(page).to have_content(updated_name)
        expect(page).to have_content(updated_schedule_end_day.strftime('%Y/%m/%d'))

        # ## 詳細ページに編集した内容が存在することを確認する
        click_link updated_name, href: task_path(task1)
        expect(page).to have_current_path(task_path(task1))
        expect(page).to have_content(updated_name)
        expect(page).to have_content(updated_memo)
        expect(page).to have_content(updated_start_day.strftime('%Y/%m/%d'))
        expect(page).to have_content(updated_schedule_end_day.strftime('%Y/%m/%d'))
        expect(page).to have_content(updated_end_day.strftime('%Y/%m/%d'))
      end
    end

    context 'タスク編集ができない時' do
      it 'ログインしたユーザーは自分以外が登録したタスクの編集画面には遷移できない' do
        sign_in(owner)

        visit edit_task_path(task2)
        expect(page).to have_current_path(root_path)
      end

      it 'ログインしていないとタスクの編集画面には遷移できない' do
        # ## トップページにいる
        visit root_path
        expect(page).to have_current_path(root_path)

        # ## 一覧ページへのボタンを押すとログイン画面に遷移する
        click_link 'タスクを登録・確認', href: tasks_path
        expect(page).to have_current_path(new_user_session_path)
      end

      it '送る値が空のため、編集に失敗する' do
        sign_in(owner)

        # ## 一覧ページに移動する
        click_link 'タスクを登録・確認', href: tasks_path
        expect(page).to have_current_path(tasks_path)

        # ## 詳細ページに移動する
        click_link task1.task_name, href: task_path(task1)
        expect(page).to have_current_path(task_path(task1))

        # ## タスク1の詳細ページに「編集」へのリンクがあることを確認する
        expect(page).to have_link('編集', href: edit_task_path(task1))

        # ## 編集ページへ遷移する
        click_link '編集', href: edit_task_path(task1)
        expect(page).to have_current_path(edit_task_path(task1))

        # ## すでに登録済みの内容がフォームに入っていることを確認する
        expect(page).to have_field('タスク名', with: task1.task_name)

        # ## 登録内容を編集し、空の状態にする
        fill_in 'タスク名', with: ''
        fill_in '開始日', with: ''
        fill_in '終了予定日', with: ''
        fill_in 'メモ', with: ''

        # ## DBは変わってないことを確認する
        expect do
          click_button 'タスクを更新'
        end.not_to change(Task, :count)

        # ## 編集ページに戻ってくることを確認する
        expect(page).to have_current_path(edit_task_path(task1))
      end
    end
  end

  describe 'C:タスク削除' do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let!(:task1) { create(:task, user: owner, task_name: '削除するタスク') }
    let!(:task2) { create(:task, user: other_user) }

    context 'タスク削除ができる時' do
      it 'ログインしたユーザーは自らが登録したタスクの削除ができる' do
        sign_in(owner)

        # ## 一覧ページに移動する
        click_link 'タスクを登録・確認', href: tasks_path
        expect(page).to have_current_path(tasks_path)

        # ## 詳細ページに移動する
        click_link task1.task_name, href: task_path(task1)
        expect(page).to have_current_path(task_path(task1))

        # ## タスク1の詳細ページに「削除」へのリンクがあることを確認する
        expect(page).to have_button('削除')

        # ## 登録を削除するとレコードの数が1減ることを確認する
        expect do
          click_button '削除'
          expect(page).to have_current_path(tasks_path, ignore_query: true)
        end.to change(Task, :count).by(-1)

        # ## 一覧ページにはタスク1が存在しないことを確認する
        expect(page).not_to have_content(task1.task_name)
      end
    end

    context 'タスク削除ができない時' do
      it 'ログインしたユーザーは自分以外が登録したタスクの削除ができない' do
        sign_in(owner)

        visit task_path(task2)
        expect(page).to have_current_path(root_path)
      end

      it 'ログインしていないとタスクの削除ボタンがないこと確認する' do
        # ## トップページに移動する
        visit root_path
        expect(page).to have_current_path(root_path)

        # ## 一覧ページへのボタンを押すとログイン画面に遷移する
        click_link 'タスクを登録・確認', href: tasks_path
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end

  describe 'D:タスク詳細表示' do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let!(:task1) do
      create(
        :task,
        user: owner,
        task_name: 'タスク詳細',
        memo: '詳細メモ',
        start_day: Date.current,
        schedule_end_day: Date.current + 2.days,
        end_day: Date.current + 3.days
      )
    end
    let!(:task2) { create(:task, user: other_user) }

    context 'タスク詳細表示できる時' do
      it 'ログインしたユーザーは自分が登録したタスク詳細ページに遷移してタスク内容が表示される' do
        sign_in(owner)

        # ## 一覧ページに移動する
        click_link 'タスクを登録・確認', href: tasks_path
        expect(page).to have_current_path(tasks_path)

        # ## 詳細ページに移動する
        click_link task1.task_name, href: task_path(task1)
        expect(page).to have_current_path(task_path(task1))

        # ## 詳細ページにタスクの詳細が含まれている
        expect(page).to have_content(task1.task_name)
        expect(page).to have_content(task1.memo)
        expect(page).to have_content(task1.start_day.strftime('%Y/%m/%d'))
        expect(page).to have_content(task1.schedule_end_day.strftime('%Y/%m/%d'))
      end
    end

    context 'タスク詳細表示ができない時' do
      it 'ログインしたユーザーは自分以外が登録したタスクの詳細表示ができない' do
        sign_in(owner)

        visit task_path(task2)
        expect(page).to have_current_path(root_path)
      end

      it 'ログインしていない状態でツイート詳細ページに遷移できない' do
        # ## トップページに移動する
        visit root_path
        expect(page).to have_current_path(root_path)

        # ## 一覧ページへのボタンを押すとログイン画面に遷移する
        click_link 'タスクを登録・確認', href: tasks_path
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end
end
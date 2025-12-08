require 'rails_helper'

RSpec.describe 'プロジェクト管理', type: :system do
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

  describe 'A:プロジェクト登録' do
    let(:user) { create(:user) }

    context 'プロジェクト登録ができる時' do
      it 'ログインしたユーザーは新規登録できる' do
        project_name = '新しいプロジェクト'
        start_day = Date.current
        schedule_end_day = Date.current + 7.days
        end_day = Date.current + 10.days
        memo = 'プロジェクトのメモ'

        sign_in(user)

        # ## 一覧ページに移動する
        if page.has_link?('プロジェクトを登録・確認', href: projects_path)
          click_link 'プロジェクトを登録・確認', href: projects_path
        else
          visit projects_path
        end
        visit projects_path unless page.current_path == projects_path
        expect(page).to have_current_path(projects_path)

        # ## 新規登録ページへのボタンがあることを確認する
        expect(page).to have_link('プロジェクト新規登録', href: new_project_path)

        # ## 登録ページに移動する
        click_link 'プロジェクト新規登録', href: new_project_path
        expect(page).to have_current_path(new_project_path)

        # ## フォームに情報を入力する
        fill_in 'プロジェクト名', with: project_name
        fill_in '開始日', with: start_day
        fill_in '終了予定日', with: schedule_end_day
        fill_in '終了日', with: end_day
        fill_in 'メモ', with: memo
        fill_in 'タスク名', with: 'タスク1'

        # ## 送信するとprojectモデルのカウントが1上がることを確認する
        expect do
          click_button 'プロジェクトを登録'
          expect(page).to have_current_path(projects_path, ignore_query: true)
        end.to change(Project, :count).by(1)

        # ## 送信した値がDBに保存されていることを確認する
        created_project = Project.order(created_at: :desc).first
        expect(created_project.project_name).to eq(project_name)
        expect(created_project.start_day.to_date).to eq(start_day)
        expect(created_project.schedule_end_day.to_date).to eq(schedule_end_day)
        expect(created_project.end_day.to_date).to eq(end_day)
        expect(created_project.memo).to eq(memo)

        # ## プロジェクト一覧ページに遷移できることを確認する
        if page.has_link?('プロジェクトを登録・確認', href: projects_path)
          click_link 'プロジェクトを登録・確認', href: projects_path
        else
          visit projects_path
        end
        expect(page).to have_current_path(projects_path)

        # ## 送信した値がブラウザに表示されていることを確認する
        expect(page).to have_content(project_name)
        expect(page).to have_content(start_day.strftime('%Y/%m/%d'))
        expect(page).to have_content(schedule_end_day.strftime('%Y/%m/%d'))
      end
    end

    context 'プロジェクト登録ができない時' do
      it 'ログインしていないと新規登録ページに遷移できない' do
        # ## トップページに移動する
        visit root_path
        expect(page).to have_current_path(root_path)

        # ## 一覧ページへのボタンを押すとログイン画面に遷移する
        click_link 'プロジェクトを登録・確認', href: projects_path
        expect(page).to have_current_path(new_user_session_path)
      end

      it '送る値が空のため、登録に失敗する' do
        sign_in(user)

          # ## 一覧ページに移動する
          if page.has_link?('プロジェクトを登録・確認', href: projects_path)
            click_link 'プロジェクトを登録・確認', href: projects_path
          else
            visit projects_path
          end
          expect(page).to have_current_path(projects_path)

        # ## 新規登録ページへのボタンがあることを確認する
        expect(page).to have_link('プロジェクト新規登録', href: new_project_path)

        # ## 新規登録ページへ遷移する
        click_link 'プロジェクト新規登録', href: new_project_path
        expect(page).to have_current_path(new_project_path)

        # ## DBに保存されていないことを確認する
        expect do
          click_button 'プロジェクトを登録'
        end.not_to change(Project, :count)

        # ## 新規登録ページに戻ってくることを確認する
        expect(page).to have_current_path(new_project_path)
      end
    end
  end

  describe 'B:プロジェクト編集' do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let!(:project1) do
      create(
        :project,
        user: owner,
        project_name: 'プロジェクト1',
        start_day: Date.current,
        schedule_end_day: Date.current + 5.days,
        end_day: Date.current + 6.days,
        memo: '元のメモ'
      )
    end
    let!(:project1_task) { create(:project_task, project: project1, user: owner, project_task_name: 'タスクA') }
    let!(:project2) { create(:project, user: other_user) }

    context 'プロジェクト編集ができる時' do
      it 'ログインしたユーザーは自分が投稿したプロジェクトの編集ができる' do
        updated_name = '編集後のプロジェクト'
        updated_start_day = Date.current + 1.day
        updated_end_day = Date.current + 8.days
        updated_schedule_end_day = Date.current + 9.days
        updated_memo = '編集後のメモ'

        sign_in(owner)

        # ## 一覧ページに移動する
        if page.has_link?('プロジェクトを登録・確認', href: projects_path)
          click_link 'プロジェクトを登録・確認', href: projects_path
        else
          visit projects_path
        end
        expect(page).to have_current_path(projects_path)

        # ## 詳細ページに移動する
        click_link project1.project_name, href: project_path(project1)
        expect(page).to have_current_path(project_path(project1))

        # ## プロジェクト1の詳細ページに「編集」へのリンクがあることを確認する
        expect(page).to have_link('編集', href: edit_project_path(project1))

        # ## プロジェクト1に「編集」へのリンクがあることを確認する
        click_link '編集', href: edit_project_path(project1)

        # ## 編集ページへ遷移する
        expect(page).to have_current_path(edit_project_path(project1))

        # ## すでに登録済みの内容がフォームに入っていることを確認する
        expect(page).to have_field('プロジェクト名', with: project1.project_name)
        expect(page).to have_field('メモ', with: project1.memo)
        expect(page).to have_field('タスク名', with: project1_task.project_task_name)

        # ## 登録内容を編集する
        fill_in 'プロジェクト名', with: updated_name
        fill_in '開始日', with: updated_start_day
        fill_in '終了予定日', with: updated_schedule_end_day
        fill_in '終了日', with: updated_end_day
        fill_in 'メモ', with: updated_memo
        fill_in 'タスク名', with: 'タスクB'

        # ## 編集してもProjectモデルのカウントは変わらないことを確認する
        expect do
          click_button 'プロジェクトを更新'
        end.not_to change(Project, :count)

        # ## 編集後の遷移先を確認し、一覧ページへ移動する
        updated_current_path = page.current_path.split('?').first
        expect([projects_path, root_path, edit_project_path(project1)]).to include(updated_current_path)

        unless updated_current_path == projects_path
          if page.has_link?('プロジェクトを登録・確認', href: projects_path)
            click_link 'プロジェクトを登録・確認', href: projects_path
          else
            visit projects_path
          end
        end
        expect(page).to have_current_path(projects_path)

        # ## 一覧ページに編集した内容が存在することを確認する
        expect(page).to have_content(updated_name)
        expect(page).to have_content(updated_schedule_end_day.strftime('%Y/%m/%d'))

        # ## 詳細ページに編集した内容が存在することを確認する
        click_link updated_name, href: project_path(project1)
        expect(page).to have_current_path(project_path(project1))
        expect(page).to have_content(updated_name)
        expect(page).to have_content(updated_memo)
        expect(page).to have_content(updated_start_day.strftime('%Y/%m/%d'))
        expect(page).to have_content(updated_schedule_end_day.strftime('%Y/%m/%d'))
        expect(page).to have_content(updated_end_day.strftime('%Y/%m/%d'))
        expect(page).to have_content('タスクB')
      end
    end

    context 'プロジェクト編集ができない時' do
      it 'ログインしたユーザーは自分以外が登録したプロジェクトの編集画面には遷移できない' do
        sign_in(owner)

        visit edit_project_path(project2)
        expect(page).to have_current_path(root_path)
      end

      it 'ログインしていないとプロジェクトの編集画面には遷移できない' do
        # ## トップページにいる
        visit root_path
        expect(page).to have_current_path(root_path)

        # ## 一覧ページへのボタンを押すとログイン画面に遷移する
        click_link 'プロジェクトを登録・確認', href: projects_path
        expect(page).to have_current_path(new_user_session_path)
      end

      it '送る値が空のため、編集に失敗する' do
        sign_in(owner)

        # ## 一覧ページに移動する
        click_link 'プロジェクトを登録・確認', href: projects_path
        expect(page).to have_current_path(projects_path)

        # ## 詳細ページに移動する
        click_link project1.project_name, href: project_path(project1)
        expect(page).to have_current_path(project_path(project1))

        # ## プロジェクト1の詳細ページに「編集」へのリンクがあることを確認する
        expect(page).to have_link('編集', href: edit_project_path(project1))

        # ## 編集ページへ遷移する
        click_link '編集', href: edit_project_path(project1)
        expect(page).to have_current_path(edit_project_path(project1))

        # ## すでに登録済みの内容がフォームに入っていることを確認する
        expect(page).to have_field('プロジェクト名', with: project1.project_name)
        expect(page).to have_field('タスク名', with: project1_task.project_task_name)

        # ## 登録内容を編集し、空の状態にする
        fill_in 'プロジェクト名', with: ''
        fill_in '開始日', with: ''
        fill_in '終了予定日', with: ''
        fill_in 'メモ', with: ''
        fill_in 'タスク名', with: ''

        # ## DBは変わってないことを確認する
        expect do
          click_button 'プロジェクトを更新'
        end.not_to change(Project, :count)

        # ## 編集ページに戻ってくることを確認する
        expect(page).to have_current_path(edit_project_path(project1))
      end
    end
  end

  describe 'C:プロジェクト削除' do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let!(:project1) { create(:project, user: owner, project_name: '削除するプロジェクト') }
    let!(:project2) { create(:project, user: other_user) }

    context 'プロジェクト削除ができる時' do
      it 'ログインしたユーザーは自らが登録したプロジェクトの削除ができる' do
        sign_in(owner)

        # ## 一覧ページに移動する
        click_link 'プロジェクトを登録・確認', href: projects_path
        expect(page).to have_current_path(projects_path)

        # ## 詳細ページに移動する
        click_link project1.project_name, href: project_path(project1)
        expect(page).to have_current_path(project_path(project1))

        # ## プロジェクト1の詳細ページに「削除」へのリンクがあることを確認する
        expect(page).to have_button('削除')

        # ## 登録を削除するとレコードの数が1減ることを確認する
        expect do
          click_button '削除'
          expect(page).to have_current_path(projects_path, ignore_query: true)
        end.to change(Project, :count).by(-1)

        # ## 一覧ページにはプロジェクト1が存在しないことを確認する
        expect(page).not_to have_content(project1.project_name)
      end
    end

    context 'プロジェクト削除ができない時' do
      it 'ログインしたユーザーは自分以外が登録したプロジェクトの削除ができない' do
        sign_in(owner)

        visit project_path(project2)
        expect(page).to have_current_path(root_path)
      end

      it 'ログインしていないとプロジェクトの削除ボタンがないことを確認する' do
        # ## トップページに移動する
        visit root_path
        expect(page).to have_current_path(root_path)

        # ## 一覧ページへのボタンを押すとログイン画面に遷移する
        click_link 'プロジェクトを登録・確認', href: projects_path
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end

  describe 'D:プロジェクト詳細表示' do
    let(:owner) { create(:user) }
    let(:other_user) { create(:user) }
    let!(:project1) do
      create(
        :project,
        user: owner,
        project_name: 'プロジェクト詳細',
        memo: '詳細メモ',
        start_day: Date.current,
        schedule_end_day: Date.current + 3.days,
        end_day: Date.current + 4.days
      )
    end
    let!(:project2) { create(:project, user: other_user) }

    context 'プロジェクト詳細表示できる時' do
      it 'ログインしたユーザーは自分が登録したプロジェクト詳細ページに遷移してプロジェクト内容が表示される' do
        sign_in(owner)

        # ## 一覧ページに移動する
        click_link 'プロジェクトを登録・確認', href: projects_path
        expect(page).to have_current_path(projects_path)

        # ## 詳細ページに移動する
        click_link project1.project_name, href: project_path(project1)
        expect(page).to have_current_path(project_path(project1))

        # ## 詳細ページにプロジェクトの詳細が含まれている
        expect(page).to have_content(project1.project_name)
        expect(page).to have_content(project1.memo)
        expect(page).to have_content(project1.start_day.strftime('%Y/%m/%d'))
        expect(page).to have_content(project1.schedule_end_day.strftime('%Y/%m/%d'))
      end
    end

    context 'プロジェクト詳細表示ができない時' do
      it 'ログインしたユーザーは自分以外が登録したプロジェクトの詳細表示ができない' do
        sign_in(owner)

        visit project_path(project2)
        expect(page).to have_current_path(root_path)
      end

      it 'ログインしていない状態でツイート詳細ページに遷移できない' do
        # ## トップページに移動する
        visit root_path
        expect(page).to have_current_path(root_path)

        # ## 一覧ページへのボタンを押すとログイン画面に遷移する
        click_link 'プロジェクトを登録・確認', href: projects_path
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe 'Calendars', type: :request do
  include Devise::Test::IntegrationHelpers
  include ActiveSupport::Testing::TimeHelpers
  include FactoryBot::Syntax::Methods

  describe 'GET /' do
    context 'ログインしていない場合' do
      it 'カレンダー画面が表示される' do
        travel_to Date.new(2024, 5, 10) do
          get root_path

          expect(response).to have_http_status(:ok)
          expect(response.body).to include('2024年5月')
        end
      end
    end

    context 'ログインしている場合' do
      let(:user) { create(:user) }

      it '正常にレスポンスが返ってくる' do
        travel_to Date.new(2024, 5, 10) do
          sign_in user

          get root_path(month: '2024-05')

          expect(response).to have_http_status(:ok)
          expect(response.body).to include('2024年5月')
        end
      end

      it 'ユーザーのプロジェクト・タスク・習慣を表示する' do
        travel_to Date.new(2024, 5, 10) do
          project = create(
            :project,
            user:, project_name: 'プロジェクトA',
            start_day: Date.new(2024, 5, 8),
            schedule_end_day: Date.new(2024, 5, 12)
          )
          task = create(
            :task,
            user:, task_name: 'タスクB',
            start_day: Date.new(2024, 5, 9),
            schedule_end_day: Date.new(2024, 5, 9)
          )
          habit = create(:habit, user:, habit_name: '習慣C', start_day: Date.new(2024, 5, 1))

          sign_in user

          get root_path(month: '2024-05')

          expect(response).to have_http_status(:ok)
          expect(response.body).to include(project.project_name)
          expect(response.body).to include(task.task_name)
          expect(response.body).to include(habit.habit_name)
        end
      end
    end
  end
end
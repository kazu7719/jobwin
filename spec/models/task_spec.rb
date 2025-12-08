require 'rails_helper'

RSpec.describe Task, type: :model do
  before do
    @task = FactoryBot.build(:task)
  end

  describe '新規登録できる場合' do
    it 'project_name、start_day、schedule_end_day、end_day、memoが存在すれば保存できる' do
      expect(@task).to be_valid
    end

    it 'end_dayが空でも保存できる' do
      @task.end_day = nil
      expect(@task).to be_valid
    end

    it 'memoが空でも保存できる' do
      @task.memo = ''
      expect(@task).to be_valid
    end
  end

  describe '新規登録できない場合' do
    it 'project_nameが空では登録できない' do
      @task.task_name = ''
      expect(@task).to be_invalid
    end

    it 'start_dayが空では登録できない' do
      @task.start_day = nil
      expect(@task).to be_invalid
    end

    it 'schedule_end_dayが空では登録できない' do
      @task.schedule_end_day = nil
      expect(@task).to be_invalid
    end

    it 'userが紐づいてないと登録できない' do
      @task.user = nil
      expect(@task).to be_invalid
    end
  end
end
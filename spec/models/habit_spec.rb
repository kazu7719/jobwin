require 'rails_helper'

RSpec.describe Habit, type: :model do
  before do
    @habit = FactoryBot.build(:habit)
  end

  describe '新規登録できる場合' do
    it 'habit_name、start_dayが存在すれば保存できる' do
      expect(@habit).to be_valid
    end
  end

  describe '新規登録できない場合' do
    it 'habit_nameが空では登録できない' do
      @habit.habit_name = ''
      expect(@habit).to be_invalid
    end

    it 'start_dayが空では登録できない' do
      @habit.start_day = nil
      expect(@habit).to be_invalid
    end

    it 'userが紐づいてないと登録できない' do
      @habit.user = nil
      expect(@habit).to be_invalid
    end
  end
end
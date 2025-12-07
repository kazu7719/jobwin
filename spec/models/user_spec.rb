require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    @user = FactoryBot.build(:user)
  end

  describe '新規登録ができる場合' do
    it 'nicknameとgoal、email、passwordとpassword_confirmationが存在すれば登録できる' do
      expect(@user).to be_valid
    end

    it 'labor_idが2以上であれば登録できる' do
      @user.labor_id = 2
      expect(@user).to be_valid
    end
  end

  describe '新規登録できない場合' do
    it 'nicknameが空では登録できない' do
      @user.nickname = ''
      expect(@user).to be_invalid
    end

    it 'goalが空では登録できない' do
      @user.goal = ''
      expect(@user).to be_invalid
    end

    it 'labor_idが1では登録できない' do
      @user.labor_id = 1
      expect(@user).to be_invalid
    end

    it 'emailが空では登録できない' do
      @user.email = ''
      expect(@user).to be_invalid
    end

    it 'passwordが空では登録できない' do
      @user.password = ''
      @user.password_confirmation = ''
      expect(@user).to be_invalid
    end

    it 'passwordとpassword_confirmationが不一致では登録できない' do
      @user.password_confirmation = 'different'
      expect(@user).to be_invalid
    end

    it 'nicknameが7文字以上では登録できない' do
      @user.nickname = 'abcdefg'
      expect(@user).to be_invalid
    end

    it '重複したemailが存在する場合は登録できない' do
      @user.save
      another_user = FactoryBot.build(:user, email: @user.email)
      expect(another_user).to be_invalid
    end

    it 'emailは@を含まないと登録できない' do
      @user.email = 'testexample.com'
      expect(@user).to be_invalid
    end

    it 'passwordが5文字以下では登録できない' do
      @user.password = '12345'
      @user.password_confirmation = '12345'
      expect(@user).to be_invalid
    end

    it 'passwordが129文字以上では登録できない' do
      long_password = 'a' * 129
      @user.password = long_password
      @user.password_confirmation = long_password
      expect(@user).to be_invalid
    end
  end
end

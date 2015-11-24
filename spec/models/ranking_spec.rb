require 'rails_helper'

describe Ranking do

  it "has a working model class" do
    user = create(:user)
    ranking = Ranking.new(member: user.id, member_data: "Something", rank: 5, score: 20)

    expect(ranking.score).to eq 20
    expect(ranking.rank).to eq 5
    expect(ranking.member).to eq user.id
    expect(ranking.user_id).to eq user.id
    expect(ranking.user).to eq user
  end

  it "has a working factory" do
    user = create(:user)
    ranking = build(:ranking, member: user.id, member_data: "Something", rank: 5, score: 20)

    expect(ranking.score).to eq 20
    expect(ranking.rank).to eq 5
    expect(ranking.member).to eq user.id
    expect(ranking.user_id).to eq user.id
    expect(ranking.user).to eq user
  end

  describe "class methods" do

    describe ".for_everyone" do
      before do
        leaderboard = UserLeaderboard.for_everyone

        15.times do |index|
          leaderboard.rank_member(index, index - 7)
        end

        @user = create(:user)
        leaderboard.rank_user(@user)
      end
      it "returns a total of 11 members arround the user in the 'everyone' leaderboard" do
        ranking = Ranking.for_everyone(id: @user.id)

        expect(ranking.length).to eq 11
        expect(ranking.first.rank).to eq 4
        expect(ranking.last.rank).to eq 14

        users_ranking = ranking.find { |r| r.user_id == @user.id }
        expect(users_ranking.rank).to eq 9
      end
    end

    describe ".for_state" do
      before do
        leaderboard = UserLeaderboard.for_state("NY")

        15.times do |index|
          leaderboard.rank_member(index, index - 7)
        end

        @user = create(:user)
        leaderboard.rank_user(@user)
      end

      it "returns a total of 11 members arround the user in the 'state' leaderboard" do
        ranking = Ranking.for_state(id: @user.id, state_code: "NY")

        expect(ranking.length).to eq 11
        expect(ranking.first.rank).to eq 4
        expect(ranking.last.rank).to eq 14

        users_ranking = ranking.find { |r| r.user_id == @user.id }
        expect(users_ranking.rank).to eq 9
      end
    end

    describe ".for_user_in_users_friend_list" do
      before do
        @user = create(:user)
        leaderboard = UserLeaderboard.for_friend_list_of_user(@user)

        15.times do |index|
          leaderboard.rank_member(index, index - 7)
        end

        leaderboard.rank_user(@user)
      end

      it "returns a total of 11 members arround the user in the user's friend list leaderboard" do
        ranking = Ranking.for_user_in_users_friend_list(user: @user)

        expect(ranking.length).to eq 11
        expect(ranking.first.rank).to eq 4
        expect(ranking.last.rank).to eq 14

        users_ranking = ranking.find { |r| r.user_id == @user.id }
        expect(users_ranking.rank).to eq 9
      end
    end

    describe ".for_friend_list" do
      before do
        @other_user = create(:user)
        leaderboard = UserLeaderboard.for_friend_list_of_user(@other_user)

        15.times do |index|
          leaderboard.rank_member(index, index - 7)
        end

        @user = create(:user)
        leaderboard.rank_user(@user)
      end

      it "returns a total of 11 members arround the user in another user's friend list leaderboard" do
        ranking = Ranking.for_friend_list(list_owner: @other_user, id: @user.id)

        expect(ranking.length).to eq 11
        expect(ranking.first.rank).to eq 4
        expect(ranking.last.rank).to eq 14

        users_ranking = ranking.find { |r| r.user_id == @user.id }
        expect(users_ranking.rank).to eq 9
      end
    end
  end
end

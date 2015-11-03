require 'rails_helper'

describe Ranking do
  describe ".for_everyone" do
    before do
      leaderboard = UserLeaderboard.for_everyone

      15.times do |index|
        leaderboard.rank_member(index, index - 7)
      end

      @user = create(:user, id: 20)
      leaderboard.rank_user(@user)
    end
    it "returns a total of 11 members arround the user in the 'everyone' leaderboard" do
      ranking = Ranking.for_everyone(id: @user.id)

      expect(ranking.length).to eq 11
      expect(ranking.first[:rank]).to eq 4
      expect(ranking.last[:rank]).to eq 14

      users_ranking = ranking.find { |r| r[:member] == "20" }
      expect(users_ranking[:rank]).to eq 9
    end
  end

  describe ".for_state" do
    before do
      leaderboard = UserLeaderboard.for_state("NY")

      15.times do |index|
        leaderboard.rank_member(index, index - 7)
      end

      @user = create(:user, id: 20)
      leaderboard.rank_user(@user)
    end

    it "returns a total of 11 members arround the user in the 'state' leaderboard" do
      ranking = Ranking.for_state(id: @user.id, state_code: "NY")

      expect(ranking.length).to eq 11
      expect(ranking.first[:rank]).to eq 4
      expect(ranking.last[:rank]).to eq 14

      users_ranking = ranking.find { |r| r[:member] == "20" }
      expect(users_ranking[:rank]).to eq 9
    end
  end

  describe ".for_user_in_users_friend_list" do
    before do
      @user = create(:user, id: 20)
      leaderboard = UserLeaderboard.for_friend_list_of_user(@user)

      15.times do |index|
        leaderboard.rank_member(index, index - 7)
      end

      leaderboard.rank_user(@user)
    end

    it "returns a total of 11 members arround the user in the user's friend list leaderboard" do
      ranking = Ranking.for_user_in_users_friend_list(user: @user)

      expect(ranking.length).to eq 11
      expect(ranking.first[:rank]).to eq 4
      expect(ranking.last[:rank]).to eq 14

      users_ranking = ranking.find { |r| r[:member] == "20" }
      expect(users_ranking[:rank]).to eq 9
    end
  end

  describe ".for_friend_list" do
    before do
      @other_user = create(:user)
      leaderboard = UserLeaderboard.for_friend_list_of_user(@other_user)

      15.times do |index|
        leaderboard.rank_member(index, index - 7)
      end

      @user = create(:user, id: 20)
      leaderboard.rank_user(@user)
    end

    it "returns a total of 11 members arround the user in another user's friend list leaderboard" do
      ranking = Ranking.for_friend_list(list_owner: @other_user, id: @user.id)

      expect(ranking.length).to eq 11
      expect(ranking.first[:rank]).to eq 4
      expect(ranking.last[:rank]).to eq 14

      users_ranking = ranking.find { |r| r[:member] == "20" }
      expect(users_ranking[:rank]).to eq 9
    end
  end
end

require 'rails_helper'

describe UserLeaderboard do
  describe ".for_everyone" do
    context "if the leaderboard does not exist" do
      it "returns or creates a leaderboard called everyone" do
        leaderboard = UserLeaderboard.for_everyone()
        expect(leaderboard.class.to_s).to eq "UserLeaderboard"
        expect(leaderboard.leaderboard_name).to eq "everyone"
        expect(leaderboard.total_members).to eq 0
      end
    end

    context "if the leaderboard already exists" do
      before do
        leaderboard = UserLeaderboard.for_everyone()
        leaderboard.rank_user(create(:user))
        leaderboard.rank_user(create(:user))
      end

      it "returns the existing leaderboard" do
        leaderboard = UserLeaderboard.for_everyone()
        expect(leaderboard.class.to_s).to eq "UserLeaderboard"
        expect(leaderboard.leaderboard_name).to eq "everyone"
        expect(leaderboard.total_members).to eq 2
      end
    end
  end

  describe ".for_state" do
    context "if the leaderboard does not exist" do
      it "returns or creates a leaderboard called everyone" do
        leaderboard = UserLeaderboard.for_state("NY")
        expect(leaderboard.class.to_s).to eq "UserLeaderboard"
        expect(leaderboard.leaderboard_name).to eq "NY"
        expect(leaderboard.total_members).to eq 0
      end
    end

    context "if the leaderboard already exists" do
      before do
        leaderboard = UserLeaderboard.for_state("NY")
        leaderboard.rank_user(create(:user))
        leaderboard.rank_user(create(:user))
      end

      it "returns the existing leaderboard" do
        leaderboard = UserLeaderboard.for_state("NY")
        expect(leaderboard.class.to_s).to eq "UserLeaderboard"
        expect(leaderboard.leaderboard_name).to eq "NY"
        expect(leaderboard.total_members).to eq 2
      end
    end
  end

  describe ".for_friend_list_of_user" do
    before do
      @user = create(:user, id: 1)
    end

    context "if the leaderboard does not exist" do
      it "returns or creates a leaderboard called everyone" do
        leaderboard = UserLeaderboard.for_friend_list_of_user(@user)
        expect(leaderboard.class.to_s).to eq "UserLeaderboard"
        expect(leaderboard.leaderboard_name).to eq "user_1_friends"
        expect(leaderboard.total_members).to eq 0
      end
    end

    context "if the leaderboard already exists" do
      before do
        leaderboard = UserLeaderboard.for_friend_list_of_user(@user)
        leaderboard.rank_user(create(:user))
        leaderboard.rank_user(create(:user))
      end

      it "returns the existing leaderboard" do
        leaderboard = UserLeaderboard.for_friend_list_of_user(@user)
        expect(leaderboard.class.to_s).to eq "UserLeaderboard"
        expect(leaderboard.leaderboard_name).to eq "user_1_friends"
        expect(leaderboard.total_members).to eq 2
      end
    end
  end

  describe "#rank_user" do
    before do
      @leaderboard = UserLeaderboard.for_everyone()
    end

    context "if the user is not in the leaderboard" do
      it "adds the user to the leaderboard" do
        user = create(:user, id: 10)
        @leaderboard.rank_user(user)
        expect(@leaderboard.total_members).to eq 1

        contents = @leaderboard.around_me(10)
        expect(contents.first[:member]).to eq "10"
        expect(contents.first[:rank]).to eq 1
        expect(contents.first[:score]).to eq 0.0
      end
    end

    context "if the user is already in the leaderboard" do
      before do
        @user = create(:user, id: 10)
        @leaderboard.rank_user(@user)
      end

      it "updates the user within the leaderboard" do
        visit = create(:visit, user: @user)
        @leaderboard.rank_user(@user)
        expect(@leaderboard.total_members).to eq 1

        contents = @leaderboard.around_me(10)
        expect(contents.first[:member]).to eq "10"
        expect(contents.first[:rank]).to eq 1
        expect(contents.first[:score]).to eq 1000.0
      end
    end
  end
end

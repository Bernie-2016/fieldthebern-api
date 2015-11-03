require "rails_helper"

describe "Rankings API" do
  describe "GET /rankings" do
    it "requires authentication" do
      get "#{host}/rankings"
      expect(last_response.status).to eq 401
    end

    context "when authenticated" do


      before do

        @user = create(:user, email: "test-user@mail.com", password: "password", state_code: "NY", total_points: 100)
        create(:visit, user: @user, address: create(:address))
        @token = authenticate(email: "test-user@mail.com", password: "password")

        everyone = UserLeaderboard.for_everyone
        3.times { |n| everyone.rank_user(create(:user, total_points: 0)) }
        everyone.rank_user(@user)

        state_ny = UserLeaderboard.for_state("NY")
        2.times { |n| state_ny.rank_user(create(:user, total_points: 0))}
        state_ny.rank_user(@user)

        state_other = UserLeaderboard.for_state("OT")
        4.times { |n| state_other.rank_user(create(:user, total_points: 0)) }
        state_other.rank_user(@user)

        friends = UserLeaderboard.for_friend_list_of_user(@user)
        6.times { |n| friends.rank_user(create(:user, total_points: 0)) }
        friends.rank_user(@user)
      end

      it "can return the rankings of 'everyone'" do
        authenticated_get "rankings", { type: "everyone" }, @token

        expect(last_response.status).to eq 200
        expect(json.data.length).to eq 4

        first_ranking = json.data.first
        expect(first_ranking.id).to eq "1"
        expect(first_ranking.type).to eq "rankings"
        expect(first_ranking.attributes.score).to eq 1000.0
        expect(first_ranking.attributes.rank).to eq 1
        expect(first_ranking.relationships.user.data.id).to eq @user.id.to_s
        expect(first_ranking.relationships.user.data.type).to eq "users"
      end
      it "can return the rankings of 'state'" do
        authenticated_get "rankings", { type: "state" }, @token

        expect(last_response.status).to eq 200
        expect(json.data.length).to eq 3

        first_ranking = json.data.first
        expect(first_ranking.id).to eq "1"
        expect(first_ranking.type).to eq "rankings"
        expect(first_ranking.attributes.score).to eq 1000.0
        expect(first_ranking.attributes.rank).to eq 1
        expect(first_ranking.relationships.user.data.id).to eq @user.id.to_s
        expect(first_ranking.relationships.user.data.type).to eq "users"
      end
      it "can return the rankings of 'friends'" do
        authenticated_get "rankings", { type: "friends" }, @token

        expect(last_response.status).to eq 200
        expect(json.data.length).to eq 7

        first_ranking = json.data.first
        expect(first_ranking.id).to eq "1"
        expect(first_ranking.type).to eq "rankings"
        expect(first_ranking.attributes.score).to eq 1000.0
        expect(first_ranking.attributes.rank).to eq 1
        expect(first_ranking.relationships.user.data.id).to eq @user.id.to_s
        expect(first_ranking.relationships.user.data.type).to eq "users"
      end
    end
  end
end

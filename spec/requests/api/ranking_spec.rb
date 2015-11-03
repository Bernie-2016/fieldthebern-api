require "rails_helper"

describe "Rankings API" do
  describe "GET /rankings" do
    it "requires authentication" do
      get "#{host}/rankings"
      expect(last_response.status).to eq 401
    end

    context "when authenticated" do

      let(:token) { authenticate(email: "test-user@mail.com", password: "password") }

      before do
        user = create(:user, email: "test-user@mail.com", password: "password", state_code: "NY")

        # I would love to somehow have this work with factory_girl or something similar, but I'm not sure how

        everyone = UserLeaderboard.for_everyone
        3.times { |n| everyone.rank_member(n.to_s, n) }
        everyone.rank_member(user.id.to_s, user.id)

        state_ny = UserLeaderboard.for_state("NY")
        2.times { |n| state_ny.rank_member(n.to_s, n) }
        state_ny.rank_member(user.id.to_s, user.id)

        state_other = UserLeaderboard.for_state("OT")
        4.times { |n| state_other.rank_member(n.to_s, n) }
        state_other.rank_member(user.id.to_s, user.id)

        friends = UserLeaderboard.for_friend_list_of_user(user)
        6.times { |n| friends.rank_member(n.to_s, n) }
        friends.rank_member(user.id.to_s, user.id)
      end

      it "can return the rankings of 'everyone'" do
        authenticated_get "rankings", { type: "everyone" }, token

        expect(last_response.status).to eq 200
        expect(json.data.length).to eq 4
      end
      it "can return the rankings of 'state'" do
        authenticated_get "rankings", { type: "state" }, token

        expect(last_response.status).to eq 200
        expect(json.data.length).to eq 3
      end
      it "can return the rankings of 'friends'" do
        authenticated_get "rankings", { type: "friends" }, token

        expect(last_response.status).to eq 200
        expect(json.data.length).to eq 7
      end
    end
  end
end

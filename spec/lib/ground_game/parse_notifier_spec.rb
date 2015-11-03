require "ground_game/parse_notifier"

module GroundGame
  describe ParseNotifier do
    describe ".ping_user" do
      # it "works"  do
      #   expect(GroundGame::ParseNotification).to receive(:send_to_device).with(message: "Ping!", device_token: "123")
      #   user= create(:user)
      #   create(:device, user: user, token: "123")
      #   ParseNotifier.ping_user(user: user)
      # end

      # it "works when user has multiple devices"
    end

    describe ".ping_channel" do
      it "works" do
        expect(GroundGame::ParseNotification).to receive(:send_to_channel).with(message: "Ping!",  channel: "test")
        ParseNotifier.ping_channel(channel: "test")
      end
    end

    describe ".friend_has_beaten_user" do
      it "works" do
        user = create(:user)
        friend_who_has_beaten_user = create(:user, first_name: "John")
        create(:device, user: friend_who_has_beaten_user, token: "123")

        expect(GroundGame::ParseNotification).to receive(:send_to_device).with(message: "Your friend John has beaten you!", device_token: "123")
        ParseNotifier.friend_has_beaten_user(user: user, friend: friend_who_has_beaten_user)
      end

      # it "works when user has multiple devices"
    end
  end
end

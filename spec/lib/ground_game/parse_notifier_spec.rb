require "ground_game/parse_notifier"

module GroundGame
  describe ParseNotifier do
    describe ".ping" do
      it "can ping a user"  do
        expect(GroundGame::ParseNotification).to receive(:send).with(message: "Ping!", channel: nil, username: "test")
        ParseNotifier.ping(username: "test")
      end

      it "can ping a channel" do
        expect(GroundGame::ParseNotification).to receive(:send).with(message: "Ping!", channel: "test", username: nil)
        ParseNotifier.ping(channel: "test")
      end
    end
  end
end

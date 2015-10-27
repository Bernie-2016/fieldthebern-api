require "ground_game/parse_notification"

module GroundGame
  describe ParseNotification do
    describe "#send" do
      it "can send to a user" do
        expect_any_instance_of(Parse::Push).to receive(:save).and_call_original

        response = ParseNotification.new(username: "test", message: "A message").send

        expect(response["result"]).to be true
      end

      it "can send to a channel" do
        expect_any_instance_of(Parse::Push).to receive(:save).and_call_original

        response = ParseNotification.new(channel: "test", message: "A message").send

        expect(response["result"]).to be true
      end
    end
  end
end

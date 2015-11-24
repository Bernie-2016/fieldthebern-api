require "ground_game/parse_notification"

module GroundGame
  describe ParseNotification do
    describe ".send_to_device" do
      it "delegates to .new.send"  do
        expect(GroundGame::ParseNotification).to receive(:new).with(message: "A message", device_token: "123").and_call_original
        expect_any_instance_of(GroundGame::ParseNotification).to receive(:send)
        ParseNotification.send_to_device(device_token: "123", message: "A message")
      end
    end

    describe ".send_to_channel" do
      it "delegates to .new.send"  do
        expect(GroundGame::ParseNotification).to receive(:new).with(message: "A message", channel: "test").and_call_original
        expect_any_instance_of(GroundGame::ParseNotification).to receive(:send)
        ParseNotification.send_to_channel(channel: "test", message: "A message")
      end
    end

    describe "#send" do
      it "can send to a devices"  do
        expect(Parse::Push).to receive(:new).with({ alert: "A message"}).and_call_original

        VCR.use_cassette "lib/ground_game/parse_notification/send_to_user" do
          response = ParseNotification.new(device_token: "test", message: "A message").send
          expect(response["result"]).to be true
        end

      end

      it "can send to a channel" do
        expect(Parse::Push).to receive(:new).with({ alert: "A message"}, "test").and_call_original

        VCR.use_cassette "lib/ground_game/parse_notification/send_to_channel" do
          response = ParseNotification.new(channel: "test", message: "A message").send
          expect(response["result"]).to be true
        end
      end
    end
  end
end

require "ground_game/parse_notification"

module GroundGame
  describe ParseNotification do
    describe "#send" do
      it "can send to a user"  do
        expect(Parse::Push).to receive(:new).with({ alert: "A message"}).and_call_original

        VCR.use_cassette "lib/ground_game/parse_notification/send_to_user" do
          response = ParseNotification.new(username: "test", message: "A message").send
          expect(response["result"]).to be true
        end

      end

      it "can send to a channel" do
        expect(Parse::Push).to receive(:new).with({ alert: "A message"}, "test").and_call_original

        # TODO: Delete and re-record the tape when we have ios set-up.
        # We need to setup an ios certificate. Right now, the tape recorded a
        # '115: To push to ios devices, you must first configure a valid certificate.' response
        VCR.use_cassette "lib/ground_game/parse_notification/send_to_channel" do
          response = ParseNotification.new(channel: "test", message: "A message").send
          expect(response["result"]).to be true
        end

      end
    end
  end
end

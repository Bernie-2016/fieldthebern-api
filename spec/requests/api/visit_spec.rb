require "rails_helper"

describe "Visit API" do
  describe "POST /visits" do
    it "requires authentication" do
      post "#{host}/visits"
      expect(last_response.status).to eq 401
    end

    context "when authenticated" do
      let(:token) { authenticate(email: "test-user@mail.com", password: "password") }

      before do
        create(:user, id: 11, email: "test-user@mail.com", password: "password")
      end

      it "should return the created visit" do
        create(:address, id: 1)

        authenticated_post "visits", {
          data: {
            attributes: {
              duration_sec: 200
            },
            relationships: {
              address: { data: { id: 1, type: "addresses" } }
            }
          },
          included: [ { id: 1, type: "addresses" } ]
        }, token

        expect(last_response.status).to eq 200

        visit_json = json.data.attributes

        expect(visit_json.duration_sec).to eq 200
        expect(visit_json.total_points).not_to be_nil
      end

      context "when address already exists" do
        context "when person already exists" do
          it "creates a visit, updates the address and the person" do
            address = create(:address, id: 1)
            create(:person, id: 10, address: address, canvas_response: :unknown, party_affiliation: :unknown_affiliation)

            authenticated_post "visits", {
              data: {
                attributes: {
                  duration_sec: 200
                },
                relationships: {
                  address: { data: { id: 1, type: "addresses" } },
                  person: { data: { id: 10, type: "people" } }
                }
              },
              included: [
                {
                  type: "addresses",
                  id: 1
                }, {
                  type: "people",
                  id: 10,
                  attributes: {
                    canvas_response: "Leaning for",
                    party_affiliation: "Democrat"
                  }
                }
              ]
            }, token

            expect(last_response.status).to eq 200

            expect(Person.count).to eq 1
            expect(Address.count).to eq 1

            modified_address = Address.find(1)
            modified_person = Person.find(10)

            expect(modified_address.most_supportive_resident).to eq modified_person

            expect(modified_person.leaning_for?).to be true
            expect(modified_person.democrat_affiliation?).to be true
          end
        end
        context "when person does not exist" do
          it "creates a visit, updates the address, creates the person"
        end

        context "when some people exist, some dont" do
          it "creates a visit, updates the address, creates people that don\'t exist, updates people that do"
        end
      end

      context "when address doesn\'t already exist" do
        it "creates a visit as well as an address and the person"
      end
    end
  end
end

require "rails_helper"

RSpec.describe UsersController, type: :controller do
  render_views

  describe "feed" do
    it "responds to turbo_stream requests", points: 1 do
      user = User.create(
        username: "test",
        email: "test@example.com",
        password: "password",
        avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg")
      )

      sign_in user

      params = {
        username: user.username,
        page: 2
      }

      get :feed, params: params, as: :turbo_stream

      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to have_tag("turbo-stream")
    end
  end
end

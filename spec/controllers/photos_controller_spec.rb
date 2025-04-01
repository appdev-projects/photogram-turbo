require "rails_helper"

RSpec.describe PhotosController, type: :controller do
  render_views

  describe "update" do
    it "responds to turbo_stream requests", points: 1 do
      owner = User.create(
        username: "test",
        email: "test@example.com",
        password: "password",
        avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg")
      )

      photo = Photo.create(
        caption: "hi there :3",
        image: File.open("#{Rails.root}/spec/support/test_image.jpeg"),
        owner: owner
      )

      sign_in owner

      params = { id: photo.id, photo: { caption: "this is a new caption" }, format: :turbo_stream }

      patch :update, params: params, as: :turbo_stream

      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to have_tag("turbo-stream")
    end
  end

  describe "destroy" do
    it "responds to turbo_stream requests", points: 1 do
      owner = User.create(
        username: "test",
        email: "test@example.com",
        password: "password",
        avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg")
      )

      photo = Photo.create(
        caption: "hi there :3",
        image: File.open("#{Rails.root}/spec/support/test_image.jpeg"),
        owner: owner
      )

      sign_in owner

      delete :destroy, params: { id: photo.id }, as: :turbo_stream

      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to have_tag("turbo-stream")
    end
  end
end

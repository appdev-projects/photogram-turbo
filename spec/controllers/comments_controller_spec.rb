require "rails_helper"

RSpec.describe CommentsController, type: :controller do
  render_views

  describe "create" do
    it "responds to turbo_stream requests", points: 1 do
      owner = User.create(
        username: "test",
        email: "test@example.com",
        password: "password",
        avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg")
      )

      author = User.create(
        username: "author",
        email: "author@example.com",
        password: "password",
        avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg")
      )

      photo = Photo.create(
        caption: "hi there :3",
        image: File.open("#{Rails.root}/spec/support/test_image.jpeg"),
        owner: owner
      )

      sign_in author

      params = {
        comment: {
          author_id: author.id,
          photo_id: photo.id,
          body: "hi there"
        }
      }

      post :create, params: params, as: :turbo_stream

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

      author = User.create(
        username: "author",
        email: "author@example.com",
        password: "password",
        avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg")
      )

      photo = Photo.create(
        caption: "hi there :3",
        image: File.open("#{Rails.root}/spec/support/test_image.jpeg"),
        owner: owner
      )

      comment = Comment.create(photo: photo, author: author, body: "hi there!")

      sign_in author

      delete :destroy, params: { id: comment.id, format: :turbo_stream }, as: :turbo_stream

      expect(response.media_type).to eq Mime[:turbo_stream]
      expect(response.body).to have_tag("turbo-stream")
    end
  end
end

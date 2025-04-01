require "rails_helper"

describe "/[USERNAME]/discover" do
  it "can be visited", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    visit "/#{user.username}/discover"

    expect(page.status_code).to be(200)
  end

  it "shows photos liked by people the current user follows", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    leader = User.create(username: "leader", email: "leader@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    owner = User.create(username: "owner", email: "owner@example.com", password: "password", private: false, avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    photo = Photo.create(image: File.open("#{Rails.root}/spec/support/test_image.jpeg"), caption: "owner caption", owner_id: owner.id)
    FollowRequest.create(sender_id: user.id, recipient_id: leader.id, status: "accepted")
    Like.create(fan_id: leader.id, photo_id: photo.id)

    visit "/#{user.username}/discover"

    expect(page).to have_content(photo.caption)
  end
end

def sign_in(user)
  visit "/users/sign_in"

  fill_in "Email", with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
end

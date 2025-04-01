require "rails_helper"

describe "/[USERNAME]/feed" do
  it "can be visited", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    visit "/#{user.username}/feed"

    expect(page.status_code).to be(200)
  end

  it "shows their leader's photos", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    leader = User.create(username: "leader", email: "leader@example.com", password: "password", private: false, avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    photo = Photo.create(image: File.open("#{Rails.root}/spec/support/test_image.jpeg"), caption: "caption", owner_id: leader.id)
    FollowRequest.create(sender_id: user.id, recipient_id: leader.id, status: "accepted")

    visit "/#{user.username}/feed"

    expect(page).to have_tag("div", with: { class: "card" }) do
      with_tag("img", with: { src: photo.image })
    end
  end

  it "allows them to like their leader's photos", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    leader = User.create(username: "leader", email: "leader@example.com", password: "password", private: false, avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    photo = Photo.create(image: File.open("#{Rails.root}/spec/support/test_image.jpeg"), caption: "caption", owner_id: leader.id)
    FollowRequest.create(sender_id: user.id, recipient_id: leader.id, status: "accepted")

    visit "/#{user.username}/feed"

    click_on "Like"

    expect(page).to have_content("Un-like")
  end

  it "allows them to un-like their leader's photos", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    leader = User.create(username: "leader", email: "leader@example.com", password: "password", private: false, avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    photo = Photo.create(image: File.open("#{Rails.root}/spec/support/test_image.jpeg"), caption: "caption", owner_id: leader.id)
    FollowRequest.create(sender_id: user.id, recipient_id: leader.id, status: "accepted")
    Like.create(fan_id: user.id, photo_id: photo.id)

    visit "/#{user.username}/feed"

    click_on "Un-like"

    expect(page).to have_content("Like")
  end

  it "allows the user to add a comment on their leader's photos", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    leader = User.create(username: "leader", email: "leader@example.com", password: "password", private: false, avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    photo = Photo.create(image: File.open("#{Rails.root}/spec/support/test_image.jpeg"), caption: "caption", owner_id: leader.id)
    FollowRequest.create(sender_id: user.id, recipient_id: leader.id, status: "accepted")

    visit "/#{user.username}/feed"

    fill_in "comment[body]", with: "New comment"
    click_button "Create Comment"

    expect(page).to have_content("New comment")
  end

  it "allows the user to delete their comment", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    leader = User.create(username: "leader", email: "leader@example.com", password: "password", private: false, avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    photo = Photo.create(image: File.open("#{Rails.root}/spec/support/test_image.jpeg"), caption: "caption", owner_id: leader.id)
    FollowRequest.create(sender_id: user.id, recipient_id: leader.id, status: "accepted")
    comment = Comment.create(body: "New comment", author_id: user.id, photo_id: photo.id)

    visit "/#{user.username}/feed"

    click_icon("i.fa-trash", first: false)

    expect(page).not_to have_content("New comment")
  end

  it "allows the user to edit their comment", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    leader = User.create(username: "leader", email: "leader@example.com", password: "password", private: false, avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    photo = Photo.create(image: File.open("#{Rails.root}/spec/support/test_image.jpeg"), caption: "caption", owner_id: leader.id)
    FollowRequest.create(sender_id: user.id, recipient_id: leader.id, status: "accepted")
    comment = Comment.create(body: "New comment", author_id: user.id, photo_id: photo.id)

    visit "/#{user.username}/feed"

    click_icon("i.fa-edit", first: false)

    fill_in "comment[body]", with: "Edited comment"
    click_button "Update Comment"

    expect(page).to have_content("Edited comment")
  end
end

def sign_in(user)
  visit "/users/sign_in"

  fill_in "Email", with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
end

def click_icon(icon_element, first: true)
  icon = if first
    all(icon_element).first
  else
    all(icon_element).last
  end

  element_to_click = icon.find(:xpath, "..")
  element_to_click.click
end

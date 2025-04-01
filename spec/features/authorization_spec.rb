require "rails_helper"

describe "Authorization" do
  it "does not allow a user to access another user's feed", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    other_user = User.create(username: "bob", email: "bob@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))

    visit "/"

    visit "/#{other_user.username}/feed"

    expect(page).to have_content("You're not authorized for that")
    expect(page).to have_current_path("/")
  end

  it "does not allow a user to access another user's discover", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    other_user = User.create(username: "bob", email: "bob@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))

    visit "/"

    visit "/#{other_user.username}/discover"

    expect(page).to have_content("You're not authorized for that")
    expect(page).to have_current_path("/")
  end

  it "does not show user icon to delete another user's photo", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    other_user = User.create(username: "bob", email: "bob@example.com", password: "password", private: false, avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    photo = Photo.create(image: File.open("#{Rails.root}/spec/support/test_image.jpeg"), caption: "caption", owner_id: other_user.id)

    visit "/photos/#{photo.id}"

    expect(page).to have_tag("div", with: { class: "card" }) do
      with_tag("img", with: { src: photo.image })
      with_text photo.caption
    end

    icon_count = all("i.fa-trash").count

    expect(icon_count).to eq(0)
  end

  it "does not show user icon to edit another user's photo", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    other_user = User.create(username: "bob", email: "bob@example.com", password: "password", private: false, avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    photo = Photo.create(image: File.open("#{Rails.root}/spec/support/test_image.jpeg"), caption: "caption", owner_id: other_user.id)

    visit "/photos/#{photo.id}"

    expect(page).to have_tag("div", with: { class: "card" }) do
      with_tag("img", with: { src: photo.image })
      with_text photo.caption
    end

    icon_count = all("i.fa-edit").count

    expect(icon_count).to eq(0)
  end

  it "does not show user icon to delete another user's comment", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    other_user = User.create(username: "bob", email: "bob@example.com", password: "password", private: false, avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    photo = Photo.create(image: File.open("#{Rails.root}/spec/support/test_image.jpeg"), caption: "caption", owner_id: other_user.id)
    comment = Comment.create(photo_id: photo.id, author_id: other_user.id, body: "comment")

    visit "/photos/#{photo.id}"

    expect(page).to have_tag("div", with: { class: "card" }) do
      with_text comment.body
    end

    icon_count = all("i.fa-trash").count

    expect(icon_count).to eq(0)
  end

  it "does not show user icon to edit another user's comment", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    other_user = User.create(username: "bob", email: "bob@example.com", password: "password", private: false, avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    photo = Photo.create(image: File.open("#{Rails.root}/spec/support/test_image.jpeg"), caption: "caption", owner_id: other_user.id)
    comment = Comment.create(photo_id: photo.id, author_id: other_user.id, body: "comment")

    visit "/photos/#{photo.id}"

    expect(page).to have_tag("div", with: { class: "card" }) do
      with_text comment.body
    end

    icon_count = all("i.fa-edit").count

    expect(icon_count).to eq(0)
  end

  it "does not show photos on a private user's profile page", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    private_user = User.create(username: "bob", email: "bob@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    photo = Photo.create(image: File.open("#{Rails.root}/spec/support/test_image.jpeg"), caption: "caption", owner_id: private_user.id)

    visit "/#{private_user.username}"

    expect(page).not_to have_tag("div", with: { class: "card" }) do
      with_tag("img", with: { src: photo.image })
    end
  end

  it "does not show another user's pending follow requests", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    other_user = User.create(username: "bob", email: "bob@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    third_user = User.create(username: "charlie", email: "charlie@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    FollowRequest.create(sender_id: other_user.id, recipient_id: third_user.id, status: "pending")

    visit "/#{third_user.username}"

    expect(page).not_to have_content("pending")
  end

  it "does not allow a user to view all photos", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    visit "/photos"

    expect(page.status_code).to be(404)
  end

  it "does not allow a user to view all likes", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    visit "/likes"

    expect(page.status_code).to be(404)
  end

  it "does not allow a user to view a like show page", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    photo = Photo.create(image: File.open("#{Rails.root}/spec/support/test_image.jpeg"), caption: "caption", owner_id: user.id)
    like = Like.create(photo_id: photo.id, fan_id: user.id)

    visit "/likes/#{like.id}"

    expect(page.status_code).to be(404)
  end

  it "does not allow a user to view a like edit page", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    photo = Photo.create(image: File.open("#{Rails.root}/spec/support/test_image.jpeg"), caption: "caption", owner_id: user.id)
    like = Like.create(photo_id: photo.id, fan_id: user.id)

    visit "/likes/#{like.id}/edit"

    expect(page.status_code).to be(404)
  end

  it "does not allow a user to view all comments", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    visit "/comments"

    expect(page.status_code).to be(404)
  end

  it "does not allow a user to view a comment show page", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    photo = Photo.create(image: File.open("#{Rails.root}/spec/support/test_image.jpeg"), caption: "caption", owner_id: user.id)
    comment = Comment.create(photo_id: photo.id, author_id: user.id, body: "comment")

    visit "/comments/#{comment.id}"

    expect(page.status_code).to be(404)
  end

  it "does not allow a user to view all follow requests", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    visit "/follow_requests"

    expect(page.status_code).to be(404)
  end

  it "does not allow a user to view a follow request show page", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    other_user = User.create(username: "bob", email: "bob@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    follow_request = FollowRequest.create(sender_id: user.id, recipient_id: other_user.id, status: "pending")

    visit "/follow_requests/#{follow_request.id}"

    expect(page.status_code).to be(404)
  end

  it "does not allow a user to view a follow request edit page", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    other_user = User.create(username: "bob", email: "bob@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    follow_request = FollowRequest.create(sender_id: user.id, recipient_id: other_user.id, status: "pending")

    visit "/follow_requests/#{follow_request.id}/edit"

    expect(page.status_code).to be(404)
  end

  it "does not allow a user to visit the edit page for another user's photo", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    other_user = User.create(username: "bob", email: "bob@example.com", password: "password", private: false, avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    photo = Photo.create(image: File.open("#{Rails.root}/spec/support/test_image.jpeg"), caption: "caption", owner_id: other_user.id)

    visit "/photos/#{photo.id}/edit"

    expect(page).to have_content("You're not authorized for that")
    expect(page).not_to have_form("/photos/#{photo.id}", :post)
  end

  it "does not allow a user to visit the edit page for another user's comment", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    other_user = User.create(username: "bob", email: "bob@example.com", password: "password", private: false, avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    photo = Photo.create(image: File.open("#{Rails.root}/spec/support/test_image.jpeg"), caption: "caption", owner_id: other_user.id)
    comment = Comment.create(photo_id: photo.id, author_id: other_user.id, body: "comment")

    visit "/comments/#{comment.id}/edit"

    expect(page).to have_content("You're not authorized for that")
    expect(page).not_to have_form("/comments/#{comment.id}", :post)
  end
end

def sign_in(user)
  visit "/users/sign_in"

  fill_in "Email", with: user.email
  fill_in "Password", with: user.password
  click_button "Sign in"
end

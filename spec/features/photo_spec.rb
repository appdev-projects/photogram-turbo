require "rails_helper"

describe "/photos/new" do
  it "has a form to add a new photo", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    visit "/photos/new"

    expect(page).to have_form("/photos", :post)
  end

  it "does not allow the user to add a new photo without a caption", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    visit "/"

    click_on "Add post"

    attach_file "Image", "#{Rails.root}/spec/support/test_image.jpeg"
    click_on "Create Photo"

    expect(page).to have_content("Caption can't be blank")
  end

  it "allows the user to add a new photo", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    visit "/"

    click_on "Add post"

    attach_file "Image", "#{Rails.root}/spec/support/test_image.jpeg"
    fill_in "Caption", with: "caption"
    click_on "Create Photo"

    expect(page).to have_content("Photo was successfully created")
  end

  it "redirects to the photo details page after creating a new photo", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    visit "/"

    click_on "Add post"

    attach_file "Image", "#{Rails.root}/spec/support/test_image.jpeg"
    fill_in "Caption", with: "caption"
    click_on "Create Photo"

    expect(page).to have_current_path("/photos/#{Photo.last.id}")
  end
end

describe "/photos/[ID]" do
  it "displays the photo and caption inside a bootstrap card", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    photo = Photo.create(image: File.open("#{Rails.root}/spec/support/test_image.jpeg"), caption: "caption", owner_id: user.id)

    visit "/photos/#{photo.id}"

    expect(page).to have_tag("div", with: { class: "card" }) do
      with_tag("img", with: { src: photo.image })
      with_text photo.caption
    end
  end

  it "allows the user to edit the photo", points: 1 do
    user = User.create(username: "alice", email: "alice@example.com", password: "password", avatar_image: File.open("#{Rails.root}/spec/support/test_image.jpeg"))
    sign_in(user)

    photo = Photo.create(image: File.open("#{Rails.root}/spec/support/test_image.jpeg"), caption: "caption", owner_id: user.id)

    visit "/photos/#{photo.id}"

    click_icon("i.fa-edit")

    fill_in "Caption", with: "new caption"
    click_on "Update Photo"

    expect(page).to have_content("new caption")
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

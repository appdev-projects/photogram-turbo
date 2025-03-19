desc "Fill the database tables with some sample data"
task sample_data: :environment do
  starting = Time.now

  FollowRequest.destroy_all
  Comment.destroy_all
  Like.destroy_all
  Photo.destroy_all
  User.destroy_all

  people = Array.new(10) do
    {
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name
    }
  end

  people << { first_name: "Alice", last_name: "Smith" }
  people << { first_name: "Bob", last_name: "Smith" }
  people << { first_name: "Carol", last_name: "Smith" }
  people << { first_name: "Dave", last_name: "Smith" }
  people << { first_name: "Eve", last_name: "Smith" }

  people.each do |person|
    username = person.fetch(:first_name).downcase
    secret = false

    if [ "alice", "carol" ].include?(username) || User.where(private: true).count <= 6
      secret = true
    end

    user = User.create(
      email: "#{username}@example.com",
      password: "password",
      username: username.downcase,
      name: "#{person[:first_name]} #{person[:last_name]}",
      bio: Faker::Lorem.paragraph(
        sentence_count: 2,
        supplemental: true,
        random_sentences_to_add: 4
      ),
      website: Faker::Internet.url,
      private: secret,
      avatar_image: "https://robohash.org/#{username}"
    )

    p user.errors.full_messages
  end

  users = User.all

  users.each do |first_user|
    users.each do |second_user|
      if rand < 0.75
        status = "accepted"
        if second_user.private?
          status = "pending"
        end
        first_user_follow_request = first_user.sent_follow_requests.create(
          recipient: second_user,
          status: status
        )

        p first_user_follow_request.errors.full_messages
      end

      if rand < 0.75
        status = "accepted"
        if first_user.private?
          status = "pending"
        end
        second_user_follow_request = second_user.sent_follow_requests.create(
          recipient: first_user,
          status: status
        )

        p second_user_follow_request.errors.full_messages
      end
    end
  end

  users.each do |user|
    rand(15).times do

      # This allows the image to display whether in a codespace, deployed, or local environment
      image_url = if ENV.fetch("CODESPACES_NAME", nil).present?
        "https://#{ENV.fetch("CODESPACES_NAME")}-3000.app.github.dev/#{rand(1..10)}.jpeg"
      elsif ENV.fetch("APPLICATION_HOST", nil).present?
        "https://#{ENV.fetch("APPLICATION_HOST")}/#{rand(1..10)}.jpeg"
      else
        "http://localhost:3000/#{rand(1..10)}.jpeg"
      end

      photo = user.own_photos.create(
        caption: Faker::Quote.jack_handey,
        image: image_url
      )

      p photo.errors.full_messages

      user.followers.each do |follower|
        if rand < 0.5
          photo.fans << follower
        end

        if rand < 0.25
          comment = photo.comments.create(
            body: Faker::Quote.jack_handey,
            author: follower
          )

          p comment.errors.full_messages
        end
      end
    end
  end

  ending = Time.now
  p "It took #{(ending - starting).to_i} seconds to create sample data."
  p "There are now #{User.count} users."
  p "There are now #{FollowRequest.count} follow requests."
  p "There are now #{Photo.count} photos."
  p "There are now #{Like.count} likes."
  p "There are now #{Comment.count} comments."
end

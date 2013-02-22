FactoryGirl.define do

  sequence :email do |n|
    "person#{n}@example.com"
  end

  sequence :username do |n|
    "user#{n}"
  end

  sequence :password do |n|
    "pass#{n}"
  end

  sequence :text do |n|
    "@title{Title something #{n} with #tag\n@fav@\n@shared@\nThis is the text\nwith #tag#{n} and #tagg#{n}"
  end

  sequence :author_id do |n|
    "anAuthor#{n}id"
  end

  factory :user do
    username
    email
    password
    password_confirmation password
    opt_in true

    factory :admin do
      admin true
    end

    factory :user_with_notes do

      ignore do
        author_id_f author_id
        notes_count
      end

      after(:create) do |user, evaluator|
        FactoryGirl.create_list(:notes, evaluator.notes_count, author_id: evaluator.author_id_f)
      end
  end

  factory :note do
    text
    author_id
  end

end
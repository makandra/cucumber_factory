FactoryBot.define do
  factory :job_offer, :class => ::JobOffer do
    transient do
      my_transient_attribute { nil }
    end

    trait :tempting_job_offer do
      transient do
        other_transient_attribute { nil }
      end
    end
    trait :risky
    trait :lucrative
  end

  factory :user, :class => User do
    transient do
      movie { nil }
      film { nil }
    end

    after(:build) do |user, evaluator|
      if user.reviewed_movies.blank? && (evaluator.movie || evaluator.film)
        user.reviewed_movies << (evaluator.movie || evaluator.film)
      end
    end
  end

  factory :movie, :class => Movie do
    transient do
      user { nil }
      user_id { nil }
    end

    after(:build) do |movie, evaluator|
      movie.reviewer = evaluator.user if evaluator.user
      movie.reviewer_id = evaluator.user_id if evaluator.user_id
    end

    trait :parent_movie_trait

    factory :subgenre_movie, traits: [:parent_movie_trait]
  end
  factory :opera, :class => Opera
  factory :payment, :class => Payment
  factory :uuid_user, :class => UuidUser
  factory :film, :class => Movie
end

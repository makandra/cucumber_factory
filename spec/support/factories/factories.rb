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
    end

    after(:build) do |user, evaluator|
      if user.reviewed_movies.blank? && evaluator.movie
        user.reviewed_movies << evaluator.movie
      end
    end
  end

  factory :movie, :class => Movie
  factory :opera, :class => Opera
  factory :payment, :class => Payment
  factory :uuid_user, :class => UuidUser
end

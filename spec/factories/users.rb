# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "tester#{n}" }
    sequence(:email) { |n| "tester#{n}@example.com" }
    password { 'password' }
    association :vendor
  end

  factory :sysadmin, class: User do
    sequence(:name) { |n| "admin#{n}" }
    sequence(:email) { |n| "admin#{n}@example.com" }
    password { 'password' }
    sysadmin { true }
    association :vendor
  end
end

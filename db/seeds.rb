# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# coding: utf-8

User.create!(name: "管理者",
             email: "admin@email.com",
             affiliation: "管理部",
             employee_number: 0,
             uid: "manage1",
             password: "password",
             password_confirmation: "password",
             designated_work_start_time: "2020-07-25 09:00:00",
             designated_work_end_time: "2020-07-25 18:00:00",
             admin: true)

2.times do |n|
  name  = Faker::Name.name
  email = "superior#{n+1}@email.com"
  affiliation = "フリーランス部"
  employee_number = "#{(n+1)*10}"
  uid = "emp#{n+1}"
  password = "password"
  designated_work_start_time = "2020-07-25 09:00:00"
  designated_work_end_time = "2020-07-25 18:00:00"
  superior = true
  User.create!(name: name,
               email: email,
               affiliation: affiliation,
               employee_number: employee_number,
               uid: uid,
               password: password,
               password_confirmation: password,
               designated_work_start_time: designated_work_start_time,
               designated_work_end_time: designated_work_end_time,
               superior: superior)
end

2.times do |n|
  name  = Faker::Name.name
  email = "sample#{n+1}@email.com"
  affiliation = "フリーランス部"
  employee_number = "#{(n+3)*10}"
  uid = "emp#{n+3}"
  password = "password"
  designated_work_start_time = "2020-07-25 09:00:00"
  designated_work_end_time = "2020-07-25 18:00:00"
  User.create!(name: name,
               email: email,
               affiliation: affiliation,
               employee_number: employee_number,
               uid: uid,
               password: password,
               password_confirmation: password,
               designated_work_start_time: designated_work_start_time,
               designated_work_end_time: designated_work_end_time)
end

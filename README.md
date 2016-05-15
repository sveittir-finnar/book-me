# BookMe

[![Build Status](https://travis-ci.org/sveittir-finnar/book-me.svg?branch=master)](https://travis-ci.org/sveittir-finnar/book-me)

## Setup

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Seed the database: `MIX_ENV=dev mix run priv/repo/seeds.exs`.
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## TODOs

* ~~Companies should only be able to update their own employees.~~
* ~~Add a test that verifies that an unconfirmed user cannot log in.~~
* ~~Put [ex_machina](https://github.com/thoughtbot/ex_machina) into use.~~
* Error handling (404, 500) etc. show proper pages
* Registration of companies (and thus their first employee).
* Actually send email confirmation when adding employees.

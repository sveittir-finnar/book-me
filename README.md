# BookMe

[![Build Status](https://travis-ci.org/sveittir-finnar/book-me.svg?branch=master)](https://travis-ci.org/sveittir-finnar/book-me)
[![Coverage Status](https://coveralls.io/repos/github/sveittir-finnar/book-me/badge.svg?branch=master)](https://coveralls.io/github/sveittir-finnar/book-me?branch=master)

## Setup

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Seed the database: `MIX_ENV=dev mix run priv/repo/seeds.exs`.
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## TODOs

* Minor tasks (not in Trello):
  - "Opening hours" widget that renders to JSON.
  - JavaScript in the `service/form.html.eex` template.
  - Actually send email confirmation when adding employees.
  - Error handling (404, 500) etc. show proper pages.
  - Add a sidebar to the "Settings" page.

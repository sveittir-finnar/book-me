# Appointments

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## TODOs

* Add a test that verifies that an unconfirmed user cannot log in.
* Registration of companies (and thus their first employee).
* Filtering staff by company in staff listing.
* Actually send email confirmation when adding employees.
* Automatically assigning company_id when adding new employees.
* TravisCI integration (lints + tests).

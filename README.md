# HomeVisitService

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix


# Home Visit Service

Home Visit Service is an Elixir/Phoenix application that helps schedule and manage home visits. Members can request visits and assign tasks, while pals can fulfill visit requests based on their availability. The application ensures data consistency using Ecto Multis and provides a user-friendly interface through Phoenix LiveView.
Features

    Members and pals can register and log in.
    Members can request visits and assign tasks to the visit.
    Pals can view available visits and fulfill them based on their availability.
    The home page adapts based on user type (member or pal).
    The application ensures that a pal cannot fulfill a visit if the member doesn't have enough minutes to allocate to it, using Ecto Multis for data consistency.

## Setup

    Clone the repository:

bash

git clone https://github.com/user/home_visit_service.git
cd home_visit_service

    Install dependencies:


`mix deps.get`

    Create and migrate the database:


`mix ecto.setup`

    Install Tailwind CSS:

`mix tailwind.install`

    Start the Phoenix server:

`mix phx.server`

Now you can visit `localhost:4000` in your browser.
## Routes

    "/" : Home page. The content adapts based on the user type (member or pal).
    "/visit-request": Members can request visits and assign tasks to the visit.
    "/available-visits": Pals can view available visits and choose to fulfill them based on their availability.

Notes

    If a pal attempts to fulfill a visit where the member doesn't have enough minutes to allocate, the action will not proceed.

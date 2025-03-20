# Fluxus

[![Gem Version](https://badge.fury.io/rb/fluxus.svg)](https://badge.fury.io/rb/fluxus)
[![build](https://github.com/Rynaro/fluxus/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Rynaro/fluxus/actions/workflows/ci.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/e86034a1a2fdc1e8e88b/maintainability)](https://codeclimate.com/github/Rynaro/fluxus/maintainability)

Fluxus [[ˈfluːk.sus]](https://en.wiktionary.org/wiki/fluxus#Latin) is a lightweight, dependencyless library that brings use cases into your Ruby applications. The library leverages Ruby's best features alongside pure object-oriented concepts to create expressive and maintainable code.

_This library takes inspiration from the Clean Architecture concepts of use cases._

## Installation

Add it to your project as a dependency:

```ruby
gem 'fluxus'
```

Or install it directly:

```ruby
gem install fluxus
```

## Why Fluxus?

A use case represents a set of business rules that your application follows to achieve a specific goal. Fluxus provides a minimal structure to organize these rules while keeping your code clean and maintainable.

Fluxus is designed to be:

- **Simple**: Minimal API with a straightforward mental model
- **Expressive**: Clear and explicit interfaces for all operations
- **Predictable**: Consistent behavior with strong guarantees
- **Chainable**: Compose multiple use cases together elegantly

## Core Concepts

Fluxus follows two main principles:

1. **Explicit Success/Failure**: Every use case explicitly returns a `Success` or `Failure` result
2. **Chainable Actions**: Results can be chained to build clean, sequential processing pipelines

## Getting Started

### Creating a Basic Use Case

Use `Fluxus::Object` for standard use cases:

```ruby
class VerifyCredentials < Fluxus::Object
  def call!(username:, password:)
    user = User.find_by(username: username)

    return Failure(type: :not_found, result: "User not found") unless user
    return Failure(type: :invalid_password, result: "Invalid password") unless user.valid_password?(password)

    Success(result: user)
  end
end

# Using the use case
VerifyCredentials
  .call!(username: "john", password: "secret123")
  .on_success { |user| log_in(user) }
  .on_failure(:not_found) { |error| show_error(error) }
  .on_failure(:invalid_password) { |error| show_error(error) }
```

### Error-Safe Use Cases

For use cases where you want automatic error handling, use `Fluxus::SafeObject`:

```ruby
class FetchUserData < Fluxus::SafeObject
  def call!(user_id:)
    user = User.find(user_id)
    profile = ProfileService.fetch_profile(user)

    Success(result: { user: user, profile: profile })
  end
end

# Using the safe use case
FetchUserData
  .call!(user_id: 123)
  .on_success { |data| render_profile(data) }
  .on_failure { |error| show_error("Could not load profile") }
  .on_exception(ActiveRecord::RecordNotFound) { |data| redirect_to_not_found }
```

With `SafeObject`, any unhandled exceptions are automatically captured and returned as a `Failure` result with type `:exception`.

## Result Objects

Every use case returns a result object that follows the `Fluxus::Results::Result` contract:

### Success

```ruby
Success(result: user)                                 # Basic success
Success(type: :created, result: { id: user.id })      # Typed success
```

### Failure

```ruby
Failure(result: "Invalid input")                      # Basic failure
Failure(type: :validation, result: errors.full_messages) # Typed failure
```

### Result Contract

All result objects expose the same core methods:

```ruby
result = Success(type: :created, result: user)

result.success?  # => true
result.failure?  # => false
result.unknown?  # => false

result.type      # => :created
result.data      # => user object
```

## Chainable Hooks

Results can be chained to add conditional behavior:

```ruby
CreateUser
  .call!(params: user_params)
  .on_success { |user| redirect_to(user_path(user)) }
  .on_success(:created) { |user| NotificationService.user_created(user) }
  .on_failure(:validation) { |errors| render :new, status: :unprocessable_entity }
  .on_failure { |_| render :error, status: :internal_server_error }
```

Type-specific hooks only run when the result matches the specified type:

```ruby
ProcessPayment
  .call!(amount: 100, user: current_user)
  .on_success(:paid) { |receipt| send_receipt(receipt) }
  .on_success(:pending) { |transaction| schedule_verification(transaction) }
  .on_failure(:insufficient_funds) { |_| redirect_to_add_funds }
  .on_failure(:card_declined) { |error| show_card_error(error) }
```

### Safe Exception Handling

When using `SafeObject`, you can handle specific exceptions:

```ruby
ImportData
  .call!(file: params[:file])
  .on_success { |results| flash[:notice] = "Imported #{results[:count]} records" }
  .on_exception(CSV::MalformedCSVError) { |_| flash[:error] = "Invalid CSV format" }
  .on_exception { |data| Bugsnag.notify(data[:exception]) }
```

## Chaining Use Cases

You can chain multiple use cases together using the `then` method:

```ruby
VerifyCredentials
  .call!(username: params[:username], password: params[:password])
  .then(GenerateAuthToken, expires_in: 24.hours)
  .then(LogLogin, ip: request.remote_ip)
  .on_success { |auth_token| cookies[:token] = auth_token }
  .on_failure { |error| render json: { error: error }, status: :unauthorized }
```

The `then` method passes the result data from the previous use case as arguments to the next one, merging any additional arguments you provide. This works differently based on the return type:

- If the result data is a hash, it's merged with any additional arguments
- If the result data is not a hash, it's passed as `result: data` to the next use case

## Advanced Usage

### Composing Complex Workflows

```ruby
def process_order(params)
  ValidateOrderParams
    .call!(params: params)
    .then(ReserveInventory)
    .then(ProcessPayment)
    .then(CreateShipment)
    .on_success { |shipment| OrderMailer.confirmation(shipment).deliver_later }
    .on_failure(:payment_declined) { |error| notify_customer(error) }
    .on_failure(:inventory_unavailable) { |items| suggest_alternatives(items) }
    .on_failure { |error| log_order_failure(error) }
end
```

### Using with Rails

Fluxus works great with Rails controllers:

```ruby
class UsersController < ApplicationController
  def create
    CreateUser
      .call!(params: user_params)
      .on_success { |user| redirect_to user_path(user), notice: "User created!" }
      .on_failure { |errors| render :new, locals: { errors: errors } }
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Rynaro/fluxus.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

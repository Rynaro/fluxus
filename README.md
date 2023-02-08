# Fluxus

[![build](https://github.com/Rynaro/fluxus/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Rynaro/fluxus/actions/workflows/ci.yml)
[![Maintainability](https://api.codeclimate.com/v1/badges/e86034a1a2fdc1e8e88b/maintainability)](https://codeclimate.com/github/Rynaro/fluxus/maintainability)


Fluxus [[ˈfluːk.sus]](https://en.wiktionary.org/wiki/fluxus#Latin) is a simple way to bring use cases to your code. The library uses what Ruby can provide and a little taste of pure object-oriented concepts.

_This library takes inspiration from the Clean Architecture concepts of use cases._

_Some similarities with [dry-monads](https://github.com/dry-rb/dry-monads) and [u-case](https://github.com/serradura/u-case) can easily be perceived. This library operates to bring interoperability with them._

## Installation

You can add as your project as a dependency:

```ruby
gem 'fluxus'
```

## Usage

An use case is a set of business instructions that will be carefully followed by the runtime code and its dependencies to achieve a great purpose. The level of complexity can vary, but _Fluxus_ is here to create readability and scope around it!

_Fluxus_ always tries to deliver more from an object-oriented paradigm than from showing itself. This means _Fluxus_ is more about directions than dependency. And that's why we call our definition classes as `Fluxus::Object` and `Fluxus::SafeObject`.

### Creating a basic Fluxus::Object

```ruby
class IsEven < Fluxus::Object
    def call!(number)
        return Failure(result: "#{number} is odd") if number.odd?

        Success(result: "#{number} is even")
    end
end

IsEven.call!(2)
```

### Creating a basic Fluxus::SafeObject

```ruby
class IsEven < Fluxus::SafeObject
    def call!(number)
        return Failure(result: "#{number} is odd") if number.odd?

        Success(result: "#{number} is even")
    end
end

IsEven.call!(2)
```

#### Differences of `Object` and `SafeObject`

While `Fluxus::Object` preserves the actual Ruby code autonomy to dictate the flow breakers like error management. `SafeObject` stays in the middle and defines safe positions by respecting the `Fluxus` contract and delivering the `Fluxus::Results::Result` interface.

This approach could be useful for some error recovery systems. Since the application will always recover from it by using the error as a dependency not a runtime flow control.


---

### The return `Flow::Results`

The expected `Fluxus` contract expects a `Fluxus::Results::Result` interface compatible as a return value.

While `Object` (and `SafeObject`) are responsible for delivering a place to hold the actual logic and control this code runtime. The `Results::Result` contract will be responsible for delivering back the necessary hooks and their processed data to the application.

We natively support two kinds of `Fluxus::Results::Result` the `Success` and `Failure`. Using this idiom is closer to the natural conception of use cases, when they fail or are successful.

#### Success

```ruby
Success(result: true)
Success(type: :shinning, result: true)
```

#### Failure

```ruby
Failure(result: false)
Failure(type: :dusty, result: false)

```

#### The `Fluxus::Results::Result` contract

All results share the same (abstract) ancestor definitions which mean they are interchangeable. This brings more coherence in your code when you are handling the most crucial part of the flow, their results.

The `Success` and `Failure` public contracts could be defined by

```ruby
success_object = Success(type: :ok, result: 1+1)

success_object.success? # => true
success_object.failure? # => false
success_object.unknown? # => false

success_object.type # => :ok
success_object.data # => 2

failure_object = Failure(type: :fail, result: 1-1)

failure_object.success? # => false
failure_object.failure? # => true
failure_object.unknown? # => false

failure_object.type # => :fail
failure_object.data # => 0

```

#### The `result` and `data` relationship

You already noticed the `Success` and `Failure` receiving `result:` but getting the data from `data`. In fact, inside the `Fluxus::Results::Result,` the actual contract handles `data` directly. But `result` is a wrapper defined by `Fluxus` to bring more meaning inside the use case concept.

#### The `type` importance

The `type` is a way to categorize the major events inside the use case. Your use case can hold a variety of `Success` and `Failure` and depend on how the business is defined different paths are taken.

The `Fluxus` also defines a default value to bring simplicity to small use cases. The default value is `:ok` for `Success` and `:error` for `Failure`.

Prefer using `symbols` for handling those types.

#### Results are chainable

Was described that `Fluxus::Results::Result` are responsible for handling the (obviously) result. This means, this also needs to control the post-use case without leaking data to the runtime void.

With this in mind, the Result implements **chainable** methods. You can call them hooks if you wish.

Each hook represents one of the expected states.

```ruby
Fluxus::Results::Result#on_success
Fluxus::Results::Result#on_failure
Fluxus::Results::Result#on_exception
```

The `on_exception` is a contract for `SafeObject`, but they are basically a `Failure` with a specialized eye for `Exception` looking.

#### Hooks are blocks

All hooks are essentially blocks, and `data` is available there. This means, you can define the code routine that will handle the `data`, and `data` is immutable. Each hook handles its own version of `data`, and this belongs there.

#### Hooks respect `self`

All hook implementation preserves the `Success` or `Failure` instance. And this brings a powerful feature to your pipeline. Use cases can chain various conclusions.



---

## Compiling the knowledge

Using the `IsEven` simple use case, let's implement a fully covered `Fluxus::Object`, so you can fully understand how to build your own use cases.

### Basic flow

```ruby
class IsEven < Fluxus::Object
    def call!(number)
        return Failure(result: "#{number} is odd") if number.odd?

        Success(result: "#{number} is even")
    end
end

def my_use_case(number)
    IsEven
        .call!(number)
        .on_success { |data| puts data << '!' }
        .on_failure { |data| puts 'Why? ' << data }
end

my_use_case(2) #=> 2 is even!
my_use_case(3) #=> Why? 3 is odd
my_use_case(nil) #=> NoMethodError
```

### Scoped Results flow

```ruby
class IsEven < Fluxus::Object
    def call!(number)
        return Failure(type: :zero, result: 'you got zero') if number.zero?
        return Failure(type: :odd, result: "#{number} is odd") if number.odd?

        Success(type: :even, result: "#{number} is even")
    end
end

def my_use_case(number)
    IsEven
        .call!(number)
        .on_success(:even) { |data| p data << '!' }
        .on_failure(:odd) { |data| p 'Why? ' << data }
        .on_failure(:zero) { |data| p data }
end

my_use_case(0) #=> you got zero
my_use_case(2) #=> 2 is even!
my_use_case(3) #=> Why? 3 is odd
my_use_case(nil) #=> NoMethodError
```

### Safe Results flow

```ruby
class IsEven < Fluxus::SafeObject
    def call!(number)
        return Failure(type: :zero, result: 'you got zero') if number.zero?
        return Failure(type: :odd, result: "#{number} is odd") if number.odd?

        Success(type: :even, result: "#{number} is even")
    end
end

def my_use_case(number)
    IsEven
        .call!(number)
        .on_success(:even) { |data| p data << '!' }
        .on_failure(:odd) { |data| p 'Why? ' << data }
        .on_failure(:zero) { |data| p data }
        .on_exception(NoMethodError) { |data| p  }
end

my_use_case(0) #=> you got zero
my_use_case(2) #=> 2 is even!
my_use_case(3) #=> Why? 3 is odd
my_use_case(nil) #=> Failure with exception: data
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Rynaro/fluxus.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

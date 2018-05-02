# About this Repository

This is a fork of the main Pact repository. It adds a new feature called provider params.

For more information about Pact, see the readme for the main Pact repository at
[github.com/pact-foundation/pact-ruby](https://github.com/pact-foundation/pact-ruby). To learn more about
how to use Pact in a Ruby project, see [their Ruby implementation guide](https://docs.pact.io/documentation/ruby.html).
Below is a description of what provider params are and how to use them. You may want to be familiar with using
regular Pact first.

## Using this Repository

This fork is not on rubygems.org, so you'll need to put this in your Gemfile:

```ruby
gem 'pact-support', github: 'tucker-m/pact-support', tag: 'pr1.0'
gem 'pact', github: 'tucker-m/pact-ruby', tag: 'pr1.0'
```

You can also use `ref: 'master'` instead of `tag` to always use the latest version (possibly with breaking changes).

## Provider Params

Provider params are parts of your request that you won't know the value of until your provider state
has been set up.

You may have some field that your API expects to be in a request that you won't know for certain
until the database has been created with some records filled in. For example, if you need to have an
API key included with each request, and an API key is tied to a user. You can't get a valid
API key until you've created a user.

This isn't a problem when using your mock service provider, which probably won't
require an API key. However, when you run your tests against an *actual* service provider, you'll need
to have that API key in the request.

When you're only running the consumer side of your tests, there's no way to get
a valid API key. In order to make a real request to the service provider, you need
to have some information that exists in the database of the service provider. This is where provider
params come in.

### Creating a provider param

Provider params are put in your request similar to the way you use `Pact.term`. Here's how to create one:

```ruby
Pact.provider_param('string with some :{param_one} and :{param_two}', {
  param_one: 'foo',
  param_two: 'bar'
})
```

`Pact.provider_param` expects two arguments: a string and a hash. The string can have values interpolated
in it with the `:{}` syntax, with a parameter name between the brackets.

The hash gives the default values
for those parameters, which are used when the test runs against the mock service provider. When running
this test against the mock service provider, that `Pact.provider_param` will say
`"string with some foo and bar"`.

### Changing parameter values in the provider state 


There's a method, `provider_param()`, that is available inside of a provider state's `set_up` block.
It takes two arguments. The first is a symbol, which should match one of the parameter names you specified
in the request. The second argument is the value to fill in for that parameter.

```ruby
provider_state 'some state' do
  set_up do
    provider_param :param_one, 'this'
    provider_param :param_two, 'that'
  end
end
```

When you do `rake pact:verify` to run this test against the actual service provider, that
`Pact.provider_param` will say
`"string with some this and that"`.

### Example

You can use provider params in the path or headers of a request, like so:

```ruby
animal_api.given('a zebra').
  upon_receiving('get an animal').
  with(
    method: :get,
    headers: {
      Authorization: Pact.provider_param(':{key}', {key: 'fake_api_key'}),
    },
    path: Pact.provider_param('/animals/:{animal_id}/profile', {animal_id: '7'}),
  ).
  will_respond_with(
    status: 200,
    body: {
      'name': 'Frank', 'species': 'zebra'
    }
  )
```

With the above code, your mock service provider can expect a request to `/animals/7/profile` with the HTTP
header `Authorization: fake_api_key`.

If those values won't work on your actual service provider, you can change them when you set up the
provider state, like so:

```ruby
provider_state 'a zebra' do
  set_up do
    api_user = User.create!
    zebra = Zebra.create!(name: 'Frank')
  
    provider_param :key, api_user.api_key
    provider_param :animal_id, zebra.id
  end
end
```

So, now when we make that request to our actual service provider, instead of having a hard-coded
zebra ID of 7, it'll be whatever the ID is of the zebra we created in the provider state. Also,
our Authorization header will have a real API key belonging to `api_user`.

### Response Body

Currently, provider params can't be used in a response body (they will be ignored). Soon, though,
you'll be able to use them in the response body. So, if you response returns the zebra's ID, you can
ensure that the ID matches the value you expect.

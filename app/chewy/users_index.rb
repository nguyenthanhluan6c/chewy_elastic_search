class UsersIndex < Chewy::Index
  settings analysis: {
    analyzer: {
      email: {
        tokenizer: 'keyword',
        filter: ['lowercase']
      }
    }
  }

  define_type User.includes(:books) do
    field :user_id, value: ->(user) { user.id }
    # field :first_name, :last_name # multiple fields without additional options
    field :email, analyzer: 'email' # Elasticsearch-related options
    # field :country, value: ->(user) { user.country.name } # custom value proc
    # field :badges, value: ->(user) { user.badges.map(&:name) } # passing array values to index
    field :books do # the same block syntax for multi_field, if `:type` is specified
      field :name
      field :desc # default data type is `string`
      # additional top-level objects passed to value proc:
    end
    field :created, type: 'date', include_in_all: false,
      value: ->{ created_at } # value proc for source object context
  end
end

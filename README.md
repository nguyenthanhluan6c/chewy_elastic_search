# TẠI SAO CHỌN CHEWY?

Chewy hỗ trợ tương đối mạnh bởi các lợi thế sau:

Multi-model indexes: cho phép index ở nhiều model có liên hệ với nhau  
Every index is observable by all the related models: tự động reindex khi change trong model và các model có liên hệ  
Bulk import everywhere  
Powerful querying DSL: hỗ trợ tối đa các query chainable, mergable and lazy  

CÀI ĐẶT

Add vào gem file


> gem 'chewy'  
sau đó bundle


> bundle

CÁCH SỬ DỤNG

Tạo file index dùng cho việc index một model, nằm trong thư mục chewy  
VD: /app/chewy/users_index.rb

```Ruby
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

```

Thêm config code để tự động reindex mỗi khi có update trên model đó

```Ruby
class User < ApplicationRecord
  has_many :books

  update_index('users#user') { users }
end

```

Đánh lệnh hoặc chạy rake để index dữ liệu vào

  
UsersIndex.import

```
Các lệnh được hỗ trợ bạn có thể tham khảo trong list sau

UsersIndex.delete # destroy index if exists
UsersIndex.delete!
 
UsersIndex.create
UsersIndex.create! # use bang or non-bang methods
 
UsersIndex.purge
UsersIndex.purge! # deletes then creates index
 
UsersIndex::User.import # import with 0 arguments process all the data specified in type definition
                        # literally, User.active.includes(:country, :badges, :projects).find_in_batches
UsersIndex::User.import User.where('rating > 100') # or import specified users scope
UsersIndex::User.import User.where('rating > 100').to_a # or import specified users array
UsersIndex::User.import [1, 2, 42] # pass even ids for import, it will be handled in the most effective way
 
UsersIndex.import # import every defined type
UsersIndex.import user: User.where('rating > 100') # import only active users to `user` type.
  # Other index types, if exists, will be imported with default scope fro
```

Bắt đầu cài đặt các query trên dữ liệu đã index được. Chewy hỗ trợ các lệnh cơ bản và cần thiết trong quá trình search dữ liệu như: tìm theo term, theo regular expression, filter các giá trị dựa theo regular expression, so sáng lớn hơn, bé hơn, nằm trong range, order, limit, offset và paginate


```Ruby
scope = UsersIndex.query(term: {name: 'foo'})
  .filter(range: {rating: {gte: 100}})
  .order(created: :desc)
  .limit(20).offset(100)
 
scope.to_a # => will produce array of UserIndex::User or other types instances
scope.map { |user| user.email }
scope.total_count # => will return total objects count
 
scope.per(10).page(3) # supports kaminari pagination
scope.explain.map { |user| user._explanation }
scope.only(:id, :email) # returns ids and emails only
 
scope.merge(other_scope) # queries could be merged
```
```Ruby

Tùy chọn một số thêm một số filter
Term filter


UsersIndex.filter{ name == 'Fred' }
UsersIndex.filter{ name != 'Johny' }

Terms filter


UsersIndex.filter{ name == ['Fred', 'Johny'] }
UsersIndex.filter{ name != ['Fred', 'Johny'] }
 
UsersIndex.filter{ name(:|) == ['Fred', 'Johny'] }
UsersIndex.filter{ name(:or) == ['Fred', 'Johny'] }
UsersIndex.filter{ name(execution: :or) == ['Fred', 'Johny'] }
 
UsersIndex.filter{ name(:&) == ['Fred', 'Johny'] }
UsersIndex.filter{ name(:and) == ['Fred', 'Johny'] }
UsersIndex.filter{ name(execution: :and) == ['Fred', 'Johny'] }
 
UsersIndex.filter{ name(:b) == ['Fred', 'Johny'] }
UsersIndex.filter{ name(:bool) == ['Fred', 'Johny'] }
UsersIndex.filter{ name(execution: :bool) == ['Fred', 'Johny'] }
 
UsersIndex.filter{ name(:f) == ['Fred', 'Johny'] }
UsersIndex.filter{ name(:fielddata) == ['Fred', 'Johny'] }
UsersIndex.filter{ name(execution: :fielddata) == ['Fred', 'Johny'] }
```
```Ruby
Regexp filter


UsersIndex.filter{ name.first == /s.*y/ }
UsersIndex.filter{ name.first =~ /s.*y/ }
 
UsersIndex.filter{ name.first != /s.*y/ }
UsersIndex.filter{ name.first !~ /s.*y/ }
 
UsersIndex.filter{ name.first(:anystring, :intersection) == /s.*y/ }
UsersIndex.filter{ name.first(flags: [:anystring, :intersection]) == /s.*y/ }
```
```Ruby
Prefix filter


UsersIndex.filter{ name =~ re' }
UsersIndex.filter{ name !~ 'Joh' }
```
```Ruby
Exists filter


UsersIndex.filter{ name? }
UsersIndex.filter{ !!name }
UsersIndex.filter{ !!name? }
UsersIndex.filter{ name != nil }
UsersIndex.filter{ !(name == nil) }
```
```Ruby
Missing filter


UsersIndex.filter{ !name }
UsersIndex.filter{ !name? }
UsersIndex.filter{ name == nil }
```
```Ruby
Range filter

UsersIndex.filter{ age > 42 }
UsersIndex.filter{ age >= 42 }
UsersIndex.filter{ age < 42 }
UsersIndex.filter{ age <= 42 }
 
UsersIndex.filter{ age == (40..50) }
UsersIndex.filter{ (age > 40) & (age < 50) }
UsersIndex.filter{ age == [40..50] }
UsersIndex.filter{ (age >= 40) & (age <= 50) }
 
UsersIndex.filter{ (age > 40) & (age <= 50) }
UsersIndex.filter{ (age >= 40) & (age < 50) }
```
```Ruby
Bool filter


UsersIndex.filter{ must(name == 'Name').should(age == 42, age == 45) }
```
```Ruby
And filter


UsersIndex.filter{ (name == 'Name') & (age < 42) }
```
```Ruby
Or filter


UsersIndex.filter{ (name == 'Name') | (age < 42) }
```
```Ruby
Match all


UsersIndex.filter{ match_all }
```
```Ruby
Has child


UsersIndex.filter{ has_child(:blog_tag).query(term: {tag: 'something'}) }
UsersIndex.filter{ has_child(:comment).filter{ user == 'john' } }
```
```Ruby
Has parent


UsersIndex.filter{ has_parent(:blog).query(term: {tag: 'something'}) }
UsersIndex.filter{ has_parent(:blog).filter{ text == 'bonsai three' } }
```


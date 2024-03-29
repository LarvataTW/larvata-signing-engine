# Larvata Rails Scaffold

提供簽核流程控制

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'larvata-signing', git: "https://github.com/LarvataTW/larvata-signing-engine.git"

```

And then execute:
```bash
$ bundle
```

Update the Larvata signing module migrations:
```bash
$ rails larvata_signing:install:migrations
```

And then execute:
```bash
$ rails g db:migrate
```

## Setting

Create an new file called `larvata_signing.rb`, this file is located at ``/config/initializers/larvata_signing.rb`.
If your app has `admin/docs` pages to manage signing data, you can add the setting with:
    Larvata::Signing.admin_doc_url = "admin_doc_url"
    Larvata::Signing.admin_search_doc_url = "admin_search_doc_url"
    Larvata::Signing.admin_signing_doc_url = "admin_signing_doc_url"
This setting will be used to generate doc page hyperlink of email, they can enter doc page very soon via hyperlink of email.

## Usage

在取得簽核單資料後，可以使用 commit 方法來進行送簽的作業。
簽核單和第一個簽核階段的狀態會由草稿（draft）變為簽核中（signing），並發送簽核通知。

```ruby
doc.commit
```

在取得簽核單資料後，可以使用 sign 方法來進行核准、駁回和加簽的作業。

```ruby
# @param current_user [User] 目前簽核的使用者
# @param signing_result [Symbol] 簽核結果分別有三種：:approve 核准、:reject 駁回、:wait 加簽
# @param comment [String] 簽核意見
# @option opt [Integer] 
#   如果是駁回，可以選擇退回的簽核階段編號。
#   如果是加簽，需要傳入加簽人員編號。
#   如果是最後一關的核准，可以傳入決行的單據編號，不傳的話就會抓取第一筆來做決行。
doc.sign(current_user, signing_result, comment, opt)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/snowild/larvata_scaffold. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

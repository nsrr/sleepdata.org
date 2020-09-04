# frozen_string_literal: true

namespace :veracode do
  desc "Create veracode account."
  task setup: :environment do
    app_name = "nsrr"
    base_url = "https://staging.partners.org/"
    login_url = "/sleepdata.org/login"
    email = "test@veracode.com"
    password = "H!yz$KmSyuKZyGdaDgDcyyJr8^EC@zwp"
    veracode = User.where(email: email).first_or_create(
      username: "veracode",
      full_name: "Veracode Test",
      password: password
    )
    if veracode.persisted?
      veracode.update confirmed_at: Time.zone.now
      puts "Veracode user #{"present".green}."
    else
      puts veracode.errors.full_messages
      puts "Veracode user #{"not created".red}."
    end
    generate_html(app_name, base_url, login_url, email, password)
  end
end

def generate_html(app_name, base_url, login_url, email, password)
  html = %Q{
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head profile="http://selenium-ide.openqa.org/profiles/test-case">
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="selenium.base" href="#{base_url}" />
<title>#{app_name}test</title>
</head>
<body>
<table cellpadding="1" cellspacing="1" border="1">
<thead>
<tr><td rowspan="1" colspan="3">slicetest</td></tr>
</thead><tbody>
<tr>
  <td>open</td>
  <td>#{login_url}</td>
  <td></td>
</tr>
<tr>
  <td>type</td>
  <td>name=user[email]</td>
  <td>#{email}</td>
</tr>
<tr>
  <td>type</td>
  <td>name=user[password]</td>
  <td>#{password}</td>
</tr>
<tr>
  <td>clickAndWait</td>
  <td>name=commit</td>
  <td></td>
</tr>
</tbody></table>
</body>
</html>
  }.strip

  file = Rails.root.join("carrierwave", "veracode-#{app_name}-login.html")

  File.write(file, html)
  puts "File written to #{file.to_s.white}"
end


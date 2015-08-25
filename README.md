www.sleepdata.org
=================

[![Build Status](https://travis-ci.org/nsrr/www.sleepdata.org.svg?branch=master)](https://travis-ci.org/nsrr/www.sleepdata.org)
[![Dependency Status](https://gemnasium.com/nsrr/www.sleepdata.org.svg)](https://gemnasium.com/nsrr/www.sleepdata.org)
[![Code Climate](https://codeclimate.com/github/nsrr/www.sleepdata.org/badges/gpa.svg)](https://codeclimate.com/github/nsrr/www.sleepdata.org)

The application that runs www.sleepdata.org. Using Rails 4.2+ and Ruby 2.2+.


## Setting up Daily Digest Emails

Edit Cron Jobs `sudo crontab -e` to run the task `lib/tasks/daily_digest.rake`

```
SHELL=/bin/bash
0 1 * * 3 source /etc/profile.d/rvm.sh && cd /var/www/www.sleepdata.org && /usr/local/rvm/gems/ruby-2.2.3/bin/bundle exec rake weekly_reviewer_digest RAILS_ENV=production
```

## Copyright [![Creative Commons 3.0](http://i.creativecommons.org/l/by-nc-sa/3.0/80x15.png)](http://creativecommons.org/licenses/by-nc-sa/3.0)

Copyright (c) 2015 NSRR. See [LICENSE](https://github.com/nsrr/www.sleepdata.org/blob/master/LICENSE) for further details.

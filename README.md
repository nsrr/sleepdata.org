www.sleepdata.org
=================

[![Build Status](https://travis-ci.org/nsrr/www.sleepdata.org.svg?branch=master)](https://travis-ci.org/nsrr/www.sleepdata.org)
[![Dependency Status](https://gemnasium.com/nsrr/www.sleepdata.org.svg)](https://gemnasium.com/nsrr/www.sleepdata.org)
[![Code Climate](https://codeclimate.com/github/nsrr/www.sleepdata.org/badges/gpa.svg)](https://codeclimate.com/github/nsrr/www.sleepdata.org)

The application that runs www.sleepdata.org. Using Rails 5.2+ and Ruby 2.5+.


## Setting up Daily Digest Emails

Edit Cron Jobs `sudo crontab -e` to run the task `lib/tasks/daily_digest.rake`

```
SHELL=/bin/bash
0 1 * * 3 source /etc/profile.d/rvm.sh && cd /var/www/www.sleepdata.org && /usr/local/rvm/gems/ruby-2.5.0/bin/bundle exec rake weekly_reviewer_digest RAILS_ENV=production
```

Refreshing Sitemap

```
SHELL=/bin/bash
0 1 * * * source /etc/profile.d/rvm.sh && cd /var/www/www.sleepdata.org && /usr/local/rvm/gems/ruby-2.5.0/bin/bundle exec rake sitemap:refresh RAILS_ENV=production
```

## Installing Mini Magick - Image Upload Resizing

In order to make full use of the `mini_magick` gem, the underlying ImageMagick
library and binaries needs to be compiled.

The following instructions are specific to CentOS and Mac OS X systems.

### Installing JPEG and PNG libraries

In order for ImageMagick to be able to handle JPEGs, the jpeg development
libraries need to be installed first.

On CentOS:

```
sudo yum -y install libjpeg libjpeg-devel libpng libpng-devel
```

On Mac OS X:

Download and install the prebuilt JPG and PNG DMG here:
http://ethan.tira-thompson.com/Mac_OS_X_Ports.html

Alternatively, you can compile them from source yourself. Mac libjpeg and libpng
can be found here: http://www.libpng.org/pub/png/libpng.html,
http://www.ijg.org/files/


### Installing ImageMagick

Installing ImageMagick from source:
http://www.imagemagick.org/script/install-source.php

```
cd ~/code/source
curl http://www.imagemagick.org/download/ImageMagick.tar.gz | tar xvz
cd ImageMagick-*
./configure

  After .configure you should see a line that includes jpeg and png:
  DELEGATES       = mpeg jng jpeg png xml zlib

make
sudo make install
```

Make executables accessible by web server process using symbolic links:

```
sudo ln -s /usr/local/bin/identify /usr/bin/identify
sudo ln -s /usr/local/bin/mogrify /usr/bin/mogrify
```

### Verifying ImageMagick installation

Type the following to verify that the installation:

```
identify --version

  Version: ImageMagick 6.8.9-7 Q16 x86_64 2014-09-09 http://www.imagemagick.org
  Copyright: Copyright (C) 1999-2014 ImageMagick Studio LLC
  Features: DPC OpenMP
  Delegates: jng jpeg png xml zlib
```

To check that PNG and JPEG support were successfully enabled, run the following
command:

```
identify -list format
```

The list should include JPEG and PNG


## License

The NSRR is released under the [MIT License](http://www.opensource.org/licenses/MIT).

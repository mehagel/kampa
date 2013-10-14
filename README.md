kampa
========

Command line Strava upload utility

Requirements
------------

[mechanize](http://mechanize.rubyforge.org/) is used to automate interactions
with Strava

    $ gem install mechanize

Configuration
-------------

Email and password can be stored (at your own risk) in
`~/.config/kampa/conf.yml`.

    # conf.yml
    strava_username = joe_athlete
    strava_password = ride_really_fast

Usage
-----

    kampa [activity-file] ...

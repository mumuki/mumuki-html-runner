
[![Stories in Ready](https://badge.waffle.io/mumuki/mumuki-html-runner.png?label=ready&title=Ready)](https://waffle.io/mumuki/mumuki-html-runner)
[![Build Status](https://travis-ci.org/mumuki/mumuki-html-runner.svg?branch=master)](https://travis-ci.org/mumuki/mumuki-html-runner)
[![Code Climate](https://codeclimate.com/github/mumuki/mumuki-html-runner/badges/gpa.svg)](https://codeclimate.com/github/mumuki/mumuki-html-runner)
[![Test Coverage](https://codeclimate.com/github/mumuki/mumuki-html-runner/badges/coverage.svg)](https://codeclimate.com/github/mumuki/mumuki-html-runner/coverage)

# mumuki-html-runner
> Sinatra server for validating HTML exercises within [Mumuki](http://github.com/mumuki)

## Prerequisites
  Install rbenv:

>You can install rbenv following the instructions of this [Link](http://uqbar-wiki.org/index.php?title=Gu%C3%ADa_de_Instalaci%C3%B3n_de_Ruby)

## Setup
 Open  the Terminal Console, located in this project's
 directory, run the following commands:

  bundle install


## RUN TESTS

Note: When running tests you may recieve a Warning like this one:

` "[2015-07-16T11:03:48.197981 #2823]  INFO -- : Not reporting  to Code Climate because ENV'CODECLIMATE_REPO_TOKEN'] is not set."`

  Don't worry about that, it doesn't mean that test is not working.


If you want to run tests by console you can do the following steps:
  Open the Terminal console and inside the Project's directory    run the following commands:

    bundle exec rspec

(that should run the expectation tests)

Also you can all the tests running the following command:

    bundle exec rake

If you want to run the test using rubymine just look for the "spec"     folder inside mumuki-html-runner project, right click on the      prevously mention folder and click on "Run all Specs..." option.

If you have done the steps correctly both ways of running test should do it successfully.


FROM ruby:2.2
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev postgresql-server-dev-all postgresql-client
WORKDIR /usr/src/app
COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/
RUN bundle install
CMD ["/usr/local/bundle/bin/foreman","start","--root","/usr/src/app"]

FROM zooniverse/ruby:2.2.1

WORKDIR /app

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y upgrade && \
    apt-get install --no-install-recommends -y git curl supervisor  && \
    apt-get clean

ADD ./Gemfile /app/
ADD ./Gemfile.lock /app/

RUN bundle install

ADD supervisord.conf /etc/supervisor/conf.d/retirement_swap.conf
ADD ./ /app

ENTRYPOINT ["/usr/bin/supervisord"]

FROM ruby:3.3.1

# Установка системных зависимостей
RUN apt-get update -qq && apt-get install -y curl nodejs npm postgresql-client \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update -qq && apt-get install -y yarn watchman

WORKDIR /app

# Копируем только package.json и yarn.lock и ставим node-модули
COPY package.json yarn.lock ./
RUN yarn install --check-files

# Копируем gemfile и lockfile, устанавливаем гемы
COPY Gemfile Gemfile.lock ./
RUN bundle install
RUN rails db:migrate

# Копируем весь остальной проект
COPY . .

EXPOSE 3000

CMD ["bin/dev"]
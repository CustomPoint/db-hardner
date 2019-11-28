FROM mongo

RUN apt update
RUN apt -y install wget

WORKDIR /root

RUN mongo admin --eval "db.createUser({ user: 'admin', pwd: 'pass', roles: [ { role: 'root', db: 'admin'} ] });"
RUN wget https://raw.githubusercontent.com/mongodb/docs-assets/primer-dataset/primer-dataset.json
RUN mongoimport --db test --collection restaurants --drop --file primer-dataset.json


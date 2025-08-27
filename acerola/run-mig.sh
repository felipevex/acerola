#!/bin/bash

haxe build-mig-helper.hxml          && \
haxe build-mig-runner.hxml          && \

cp ./build/mig-helper/run.n /repo/run.n                                 && \
mkdir -p /repo/mig-runner                                               && \
cp ./build/mig-runner/MigRunner.js /repo/mig-runner/MigRunner.js        && \


# rm -rf ./build/mig-test             && \
# mkdir ./build/mig-test              && \

export MIGRATION_HOST="mysql9"
export MIGRATION_USER="root"
export MIGRATION_PASSWORD="mysql_root_password"
export MIGRATION_PORT="3306"

neko ./build/mig-helper/run.n $@ /repo

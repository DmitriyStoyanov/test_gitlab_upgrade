#!/bin/bash

sudo apt-get update
sudo apt-add-repository ppa:ansible/ansible-2.9
sudo apt-get update
sudo apt-get install ansible python -y
cd /tmp/ansible || exit
ansible-galaxy install -r requirements.yml

function background_migration_in_progress() {
  background_migration=$(sudo gitlab-rails console <<< "puts Sidekiq::Queue.new('background_migration').size"|grep "^[0-9]")
  if [ "$background_migration" != '0' ]
  then
    true
  else
    background_migration_worker=$(sudo gitlab-rails console <<< "Sidekiq::ScheduledSet.new.select { |r| r.klass == 'BackgroundMigrationWorker' }.size"|grep "^[0-9]")
    if [ "$background_migration_worker" != '0' ]
    then
      true
    else
      false
    fi
  fi
}

function gitlab_install {
        gitlab_version=$1
        if [ -f "/usr/bin/gitlab-rails" ];
        then
          echo "Waiting for background migration to complete"
          date
          while background_migration_in_progress
          do
            echo "background migration still in progress..."
            sleep 60
          done
        fi
        date
        echo Installation of Gitlab version "$gitlab_version"
        sudo ansible-playbook --connection=local --inventory 127.0.0.1, playbook.yml --extra-vars "gitlab_version=$gitlab_version"
        date
}

gitlab_install 11.10.8-ce.0
gitlab_install 11.11.8-ce.0
gitlab_install 12.0.12-ce.0
gitlab_install 12.5.7-ce.0
gitlab_install 12.10.11-ce.0
gitlab_install 13.0.6-ce.0
gitlab_install

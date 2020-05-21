#!/usr/bin/env bash
set -euo pipefail

apt-get update -y
apt-get install -y volatility
# cp /vagrant/task1/Ubuntu_4.15.0-72-generic_profile.zip /usr/lib/python2.7/dist-packages/volatility/plugins/overlays/linux
# cp /vagrant/task2/Ubuntu_4.15.0-72-generic_profile.zip /usr/lib/python2.7/dist-packages/volatility/plugins/overlays/linux
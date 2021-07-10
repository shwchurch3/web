#!/bin/bash

#cd /home/ec2-user/hugo/github/hugo-theme/
cd "$(dirname "$0")"
cd ..
hugo server -D --baseUrl=http://54.151.194.5:1313/ --bind=0.0.0.0

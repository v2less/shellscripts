#!/bin/bash
gpg -d user_cr.csv.gpg > user_cr.csv
aws configure import --csv ./user_cr.csv
rm -rf user_cr.csv
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 553336566444.dkr.ecr.us-east-2.amazonaws.com


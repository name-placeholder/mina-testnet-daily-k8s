#!/usr/bin/env sh

HELM_ARGS="--values=values.yaml --set-file=mina.runtimeConfig=resources/daemon.json"

helm upgrade --install seeds mina/helm/seed-node $HELM_ARGS
helm upgrade --install producers mina/helm/block-producer $HELM_ARGS
helm upgrade --install nodes mina/helm/plain-node $HELM_ARGS
helm upgrade --install snark-worker mina/helm/snark-worker/ $HELM_ARGS --set-file=publicKey=resources/key-05.pub
helm upgrade --install frontend mina/helm/openmina-frontend/ $HELM_ARGS

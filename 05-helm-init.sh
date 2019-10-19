#!/bin/bash -e

kubectl create ns helm
kubectl create sa -n helm tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount helm:tiller

helm init --tiller-namespace helm --service-account tiller --tiller-image=jessestuart/tiller

echo "Tiller is running in it's own namespace. export TILLER_NAMESPACE so helm can find tiller."
echo "export TILLER_NAMESPACE=helm"
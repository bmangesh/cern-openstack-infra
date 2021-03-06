#!/bin/bash

#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

set -xe

#NOTE: Lint and package chart
make grafana

tee /tmp/grafana.yaml <<EOF
manifests:
  network_policy: true
network_policy:
  grafana:
    ingress:
      - from:
        - podSelector:
            matchLabels:
              application: grafana
        ports:
        - protocol: TCP
          port: 3000
        - protocol: TCP
          port: 80
EOF


#NOTE: Deploy command
helm upgrade --install grafana ./grafana \
    --namespace=osh-infra \
    --values=/tmp/grafana.yaml

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh osh-infra

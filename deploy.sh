#!/bin/sh
docker build -t hub.home.dev/blog/tw ./
docker push hub.home.dev/blog/tw
curl -X PUT \
  -H "Content-Type: application/yaml" \
  -H "Cookie: KuboardUsername=admin; KuboardAccessKey=wphzwbi8df4f.ybs2pcye7p2mz6in5bez42jtdibi6iai" \
  -d '{"kind":"deployments","namespace":"default","name":"twblog"}' \
  "https://board.home.dev/kuboard-api/cluster/default/kind/CICDApi/admin/resource/restartWorkload"

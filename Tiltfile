# Tilt is a tool for quickly iterating on services deployed on kubernetes
# Install it from tilt.dev and run `tilt up`
# Pre-requisites: docker & kubectl configured for a cluster (either local in Kind or cloud)

k8s_yaml([
  ('config/' + f) for f in [
    'locationserver-deployment.yaml',
    'locationserver-service.yaml',
    'php-and-nginx-pod-deployment.yaml',
    'php-and-nginx-service.yaml',
    'server-nginx-config.yaml',
    'tile38-pod.yaml',
    'tile38-service.yaml',
    'ingress/ingress-service.yaml',
  ]
])

docker_build(
  'thelocal/coopcycle-web',
  '../coopcycle-web',
  dockerfile='../coopcycle-web/docker/php/Dockerfile',
  live_update=[
    sync('../coopcycle-web/app', '/server/app'),
    sync('../coopcycle-web/src', '/server/src'),
    sync('../coopcycle-web/templates', '/server/templates'),
    sync('../coopcycle-web/web', '/server/web'),
  ]
)
docker_build(
  'thelocal/coopcycle-locationserver',
  '../coopcycle-web',
  dockerfile='../coopcycle-web/docker/locationserver/Dockerfile',
)

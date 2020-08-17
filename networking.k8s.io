apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  annotations:
    networking.gke.io/v1beta1.FrontendConfig: "frontendconfig"
...

apiVersion: v1
kind: Service
metadata:
  annotations:
    cloud.google.com/backend-config: '{"default": "my-backendconfig"}'
...

apiVersion: v1
kind: Service
metadata:
  annotations:
    cloud.google.com/backend-config: '{"ports": {
    "port-1":"backendconfig-1",
    "port-2":"backendconfig-2"
    }}'
spec:
  ports:
  - name:service-name-1
    port: 8001
    protocol: TCP
    targetPort: service-port-1
  - name: service-name-2
    port: 8002
    protocol: TCP
    targetPort: service-port-2
...

apiVersion: networking.gke.io/v1beta1
kind: FrontendConfig
metadata:
  name: my-frontend-config
spec:
  sslPolicy: gke-ingress-ssl-policy

apiVersion: cloud.google.com/v1beta1
kind: BackendConfig
metadata:
  name: my-backendconfig
spec:
  timeoutSec: 40

apiVersion: cloud.google.com/v1beta1
kind: BackendConfig
metadata:
  name: my-backendconfig
spec:
  cdn:
    enabled: cdnEnabled
    cachePolicy:
      includeHost: includeHost
      includeProtocol:includeProtocol
      includeQueryString: includeQueryString
      queryStringBlacklist:queryStringBlacklist
      queryStringWhitelist: queryStringWhitelist

apiVersion: cloud.google.com/v1beta1
kind: BackendConfig
metadata:
  name: my-backendconfig
spec:
  connectionDraining:
    drainingTimeoutSec: 60

apiVersion: cloud.google.com/v1
kind: BackendConfig
metadata:
  name: my-backendconfig
spec:
  healthCheck:
    checkIntervalSec: interval
    timeoutSec: timeout
    healthyThreshold: health-threshold
    unhealthyThreshold: unhealthy-threshold
    type: protocol
    requestPath: path
    port: port

apiVersion: cloud.google.com/v1
kind: BackendConfig
metadata:
  namespace: cloud-armor-how-to
  name: my-backendconfig
spec:
  securityPolicy:
    name: "example-security-policy"

apiVersion: cloud.google.com/v1beta1
kind: BackendConfig
metadata:
  name: my-backendconfig
spec:
  logging:
    enable: true
    sampleRate: 0.5

apiVersion: cloud.google.com/v1
kind: BackendConfig
metadata:
  name:  my-backendconfig
spec:
  iap:
    enabled: true
    oauthclientCredentials:
      secretName: my-secret

apiVersion: cloud.google.com/v1beta1
kind: BackendConfig
metadata:
  name: my-backendconfig
spec:
  sessionAffinity:
    affinityType: "CLIENT_IP"

apiVersion: cloud.google.com/v1beta1
kind: BackendConfig
metadata:
  name: my-backendconfig
spec:
  sessionAffinity:
    affinityType: "GENERATED_COOKIE"
    affinityCookieTtlSec: 50

apiVersion: cloud.google.com/v1beta1
kind: BackendConfig
metadata:
  name: my-backendconfig
spec:
  customRequestHeaders:
    headers:
    - "X-Client-Region:{client_region}"
    - "X-Client-City:{client_city}"
    - "X-Client-CityLatLong:{client_city_lat_long}"

# my-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
spec:
  selector:
    matchLabels:
      purpose: bsc-config-demo
  replicas: 2
  template:
    metadata:
      labels:
        purpose: bsc-config-demo
    spec:
      containers:
      - name: hello-app-container
        image: gcr.io/google-samples/hello-app:1.0

kubectl apply -f my-deployment.yaml

# my-backendconfig.yaml
apiVersion: cloud.google.com/v1
kind: BackendConfig
metadata:
  name: my-backendconfig
spec:
  timeoutSec: 40
  connectionDraining:
    drainingTimeoutSec: 60

kubectl apply -f my-backendconfig.yaml

# my-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
  labels:
    purpose: bsc-config-demo
  annotations:
    cloud.google.com/backend-config: '{"ports": {"80":"my-backendconfig"}}'
    cloud.google.com/neg: '{"ingress": true}'
spec:
  type: ClusterIP
  selector:
    purpose: bsc-config
  ports:
  - port: 80
    protocol: TCP
    targetPort: 8080

kubectl apply -f my-service.yaml

apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: my-ingress
spec:
  rules:
  - http:
      paths:
      - path: /*
        backend:
          serviceName: my-service
          servicePort: 80

kubectl apply -f my-ingress.yaml

kubectl describe ingress my-ingress | grep ingress.kubernetes.io/backends

ingress.kubernetes.io/backends: '{"k8s1-27fde173-default-my-service-80-8d4ca500":"HEALTHY","k8s1-27fde173-kube-system-default-http-backend-80-18dfe76c":"HEALTHY"}

# Optionally, set a variable
export BES=k8s1-27fde173-default-my-service-80-8d4ca500

# Filter for drainingTimeoutSec and timeoutSec
gcloud compute backend-services describe ${BES} --global | grep -e "drainingTimeoutSec" -e "timeoutSec"

  drainingTimeoutSec: 60
  timeoutSec: 40

kubectl ingress my-ingress
kubectl service my-service
kubectl backendconfig my-backendconfig
kubectl deployment my-deployment

apiVersion: cloud.google.com/v1
kind: BackendConfig
metadata:
  name: my-backendconfig
spec:
  cdn:
    enabled: 
  securityPolicy:
    name: ""

kubectl get event

KIND    ... SOURCE
Ingress ... loadbalancer-controller

MESSAGE
during sync: getting BackendConfig for port 80 on service "default/my-service":
no BackendConfig for service port exists

kubectl get event

KIND    ... SOURCE
Ingress ... loadbalancer-controller

MESSAGE
during sync: The given security policy "my-policy" does not exist.

```bash
  ██████╗██╗  ██╗ █████╗ ██████╗ 
 ██╔════╝██║ ██╔╝██╔══██╗██╔══██╗
 ██║     █████╔╝ ███████║██║  ██║
 ██║     ██╔═██╗ ██╔══██║██║  ██║
 ╚██████╗██║  ██╗██║  ██║██████╔╝
  ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ 
```
> **Disclaimer:** These practice questions are designed as a brush-up in your preparation for CKAD 2025.

---

## Table of Contents

- [Question 1 – Create Secret from Hardcoded Variables](#question-1)
- [Question 2 – Create CronJob with Schedule and History Limits](#question-2)
- [Question 3 – Create ServiceAccount, Role, and RoleBinding](#question-3)
- [Question 4 – Fix Broken Pod with Correct ServiceAccount](#question-4)
- [Question 5 – Build Container Image and Save as Tarball](#question-5)
- [Question 6 – Create Canary Deployment with Manual Traffic Split](#question-6)
- [Question 7 – Fix NetworkPolicy by Updating Pod Labels](#question-7)
- [Question 8 – Fix Broken Deployment YAML](#question-8)
- [Question 9 – Perform Rolling Update and Rollback](#question-9)
- [Question 10 – Add Readiness Probe to Deployment](#question-10)
- [Question 11 – Configure Pod and Container Security Context](#question-11)
- [Question 12 – Fix Service Selector](#question-12)
- [Question 13 – Create NodePort Service](#question-13)
- [Question 14 – Create Ingress Resource](#question-14)
- [Question 15 – Fix Ingress PathType](#question-15)
- [Question 16 – Add Resource Requests and Limits to Pod](#question-16)
- [Question 17 – Fix labels to match existing NetworkPolicies](#question-17)
- [Question 18 – Canary Deployment](#question-18)

---

<a id="question-1"></a>
## Question 1 – Create Secret from Hardcoded Variables

### Problem Statement
In namespace `default`, Deployment `api-server` exists with hard-coded environment variables (`DB_USER=admin`, `DB_PASS=Secret123!`).
1. Create a Secret named `db-credentials` containing these credentials.
2. Update Deployment `api-server` to use the Secret via `valueFrom.secretKeyRef`.

### Setup Script
```bash
kubectl create deploy api-server --image=nginx --replicas=1
kubectl set env deploy/api-server DB_USER=admin DB_PASS=Secret123!
```

### Solution
```bash
# 1. Create Secret
kubectl create secret generic db-credentials \
  --from-literal=DB_USER=admin \
  --from-literal=DB_PASS=Secret123! \
  -n default

# 2. Update Deployment to use Secret
kubectl set env deploy/api-server --from=secret/db-credentials --prefix="" -n default
# OR edit manually:
# kubectl edit deploy api-server -n default
# env:
#   - name: DB_USER
#     valueFrom:
#       secretKeyRef:
#         name: db-credentials
#         key: DB_USER
#   - name: DB_PASS
#     valueFrom:
#       secretKeyRef:
#         name: db-credentials
#         key: DB_PASS
```

---

<a id="question-2"></a>
## Question 2 – Create CronJob with Schedule and History Limits

### Problem Statement
Create a CronJob named `backup-job` in namespace `default`:
- Schedule: `*/30 * * * *`
- Image: `busybox:latest`, Command: `echo "Backup completed"`
- `successfulJobsHistoryLimit`: 3
- `failedJobsHistoryLimit`: 2
- `activeDeadlineSeconds`: 300
- `restartPolicy`: Never

### Setup Script
*(None - create new resource)*

### Solution
```yaml
# kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-job
  namespace: default
spec:
  schedule: "*/30 * * * *"
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 2
  jobTemplate:
    spec:
      activeDeadlineSeconds: 300
      template:
        spec:
          restartPolicy: Never
          containers:
            - name: backup
              image: busybox:latest
              command: ["/bin/sh", "-c", "echo Backup completed"]
EOF
```

---

<a id="question-3"></a>
## Question 3 – Create ServiceAccount, Role, and RoleBinding

### Problem Statement
In namespace `audit`, Pod `log-collector` fails to list pods.
1. Create ServiceAccount `log-sa`.
2. Create Role `log-role` with `get`, `list`, `watch` on `pods`.
3. Bind them with RoleBinding `log-rb`.
4. Update Pod `log-collector` to use `log-sa`.

### Setup Script
```bash
kubectl create ns audit
kubectl run log-collector --image=nginx -n audit
```

### Solution
```bash
kubectl create sa log-sa -n audit

kubectl create role log-role --verb=get,list,watch --resource=pods -n audit

kubectl create rolebinding log-rb --role=log-role --serviceaccount=audit:log-sa -n audit

# Recreate Pod with SA
kubectl get pod log-collector -n audit -o yaml > log.yaml
kubectl delete pod log-collector -n audit
# Edit log.yaml: set spec.serviceAccountName: log-sa
# kubectl apply -f log.yaml
# OR simpler one-liner for exam:
kubectl run log-collector --image=nginx --serviceaccount=log-sa -n audit --dry-run=client -o yaml | kubectl apply -f -
```

---

<a id="question-4"></a>
## Question 4 – Fix Broken Pod with Correct ServiceAccount

### Problem Statement
In `monitoring` namespace, Pod `metrics-pod` uses `wrong-sa` and fails. Identify the correct SA (bound to a Role with pod permissions) and update the Pod.

### Setup Script
```bash
kubectl create ns monitoring
kubectl create sa monitor-sa -n monitoring
kubectl create sa wrong-sa -n monitoring
kubectl create role metrics-reader --verb=list --resource=pods -n monitoring
kubectl create rolebinding monitor-binding --role=metrics-reader --serviceaccount=monitoring:monitor-sa -n monitoring
kubectl run metrics-pod --image=nginx --serviceaccount=wrong-sa -n monitoring
```

### Solution
```bash
# Identify SA
kubectl describe rolebinding monitor-binding -n monitoring # Shows monitor-sa

# Update Pod
kubectl get pod metrics-pod -n monitoring -o yaml > pod.yaml
kubectl delete pod metrics-pod -n monitoring
sed -i 's/serviceAccountName: wrong-sa/serviceAccountName: monitor-sa/' pod.yaml
kubectl apply -f pod.yaml
```

---

<a id="question-5"></a>
## Question 5 – Build Container Image with Podman and Save as Tarball

### Problem Statement
Use existing Dockerfile in `/root/app-source`.
1. Build image `my-app:1.0` using Podman.
2. Save to `/root/my-app.tar`.

### Setup Script
```bash
mkdir -p /root/app-source
echo "FROM alpine" > /root/app-source/Dockerfile
```

### Solution
```bash
cd /root/app-source
podman build -t my-app:1.0 .
podman save -o /root/my-app.tar my-app:1.0
```

---

<a id="question-6"></a>
## Question 6 – Create Canary Deployment with Manual Traffic Split

### Problem Statement
1. Scale existing `web-app` (v1) to 8 replicas.
2. Create `web-app-canary` (v2) with 2 replicas.
3. Ensure Service `web-service` selects both.

### Setup Script
```bash
kubectl create deploy web-app --image=nginx:latest --replicas=5
kubectl label deploy web-app app=webapp version=v1 --overwrite
kubectl create svc clusterip web-service --tcp=80:80
kubectl patch svc web-service -p '{"spec":{"selector":{"app":"webapp"}}}'
```

### Solution
```bash
# 1. Scale existing
kubectl scale deploy web-app --replicas=8

# 2. Create Canary
kubectl create deploy web-app-canary --image=nginx:latest --replicas=2
kubectl label deploy web-app-canary app=webapp version=v2 --overwrite

# 3. Verify
kubectl get ep web-service # Should have 10 endpoints
```

---

<a id="question-7"></a>
## Question 7 – Fix NetworkPolicy by Updating Pod Labels

### Problem Statement
Update Pod labels in `network-demo` to flow: `frontend` -> `backend` -> `database`, matching existing NetworkPolicies.

### Setup Script
```bash
kubectl create ns network-demo
kubectl run frontend --image=nginx -n network-demo --labels=role=wrong
kubectl run backend --image=nginx -n network-demo --labels=role=wrong
kubectl run database --image=nginx -n network-demo --labels=role=wrong
# (Assume NetPols exist for role=frontend -> role=backend -> role=db)
```

### Solution
```bash
kubectl label pod frontend -n network-demo role=frontend --overwrite
kubectl label pod backend -n network-demo role=backend --overwrite
kubectl label pod database -n network-demo role=db --overwrite
```

---

<a id="question-8"></a>
## Question 8 – Fix Broken Deployment YAML

### Problem Statement
Fix `/root/broken-deploy.yaml`:
1. Update `apiVersion` to `apps/v1`.
2. Add missing `selector`.

### Setup Script
```bash
cat <<EOF > /root/broken-deploy.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: broken-app
spec:
  replicas: 2
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: web
          image: nginx
EOF
```

### Solution
```yaml
# Edit /root/broken-deploy.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: broken-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: web
          image: nginx
```
`kubectl apply -f /root/broken-deploy.yaml`

---

<a id="question-9"></a>
## Question 9 – Perform Rolling Update and Rollback

### Problem Statement
1. Update Deployment `app-v1` image to `nginx:1.25`.
2. Rollback to previous version.

### Setup Script
```bash
kubectl create deploy app-v1 --image=nginx:1.20 --replicas=2
```

### Solution
```bash
# Update
kubectl set image deploy/app-v1 nginx=nginx:1.25
kubectl rollout status deploy/app-v1

# Rollback
kubectl rollout undo deploy/app-v1
kubectl rollout status deploy/app-v1
```

---

<a id="question-10"></a>
## Question 10 – Add Readiness Probe to Deployment

### Problem Statement
Add readiness probe to `api-deploy`:
- `httpGet`: path `/ready`, port `8080`
- `initialDelaySeconds`: 5, `periodSeconds`: 10

### Setup Script
```bash
kubectl create deploy api-deploy --image=nginx --replicas=2
```

### Solution
```bash
kubectl edit deploy api-deploy
# Add to container spec:
# readinessProbe:
#   httpGet:
#     path: /ready
#     port: 8080
#   initialDelaySeconds: 5
#   periodSeconds: 10
```

---

<a id="question-11"></a>
## Question 11 – Configure Pod and Container Security Context

### Problem Statement
For Deployment `secure-app`:
1. Pod: `runAsUser: 1000`.
2. Container `app`: capability `NET_ADMIN`.

### Setup Script
```bash
kubectl create deploy secure-app --image=nginx --replicas=1
```

### Solution
```bash
kubectl edit deploy secure-app
# Pod spec:
# securityContext:
#   runAsUser: 1000
# Container spec:
# securityContext:
#   capabilities:
#     add: ["NET_ADMIN"]
```

---

<a id="question-12"></a>
## Question 12 – Fix Service Selector

### Problem Statement
Fix `web-svc` to correctly select Pods from Deployment `web-app`.

### Setup Script
```bash
kubectl create deploy web-app --image=nginx --replicas=1
kubectl label deploy web-app app=webapp --overwrite
kubectl create svc clusterip web-svc --tcp=80:80
kubectl patch svc web-svc -p '{"spec":{"selector":{"app":"wrong"}}}'
```

### Solution
```bash
kubectl patch svc web-svc -p '{"spec":{"selector":{"app":"webapp"}}}'
```

---

<a id="question-13"></a>
## Question 13 – Create NodePort Service

### Problem Statement
Create Service `api-nodeport` (NodePort) exposing Deployment `api-server` (label `app=api`) on service port 80, target port 9090.

### Setup Script
```bash
kubectl create deploy api-server --image=nginx --replicas=1
kubectl label deploy api-server app=api --overwrite
```

### Solution
```bash
kubectl create service nodeport api-nodeport --tcp=80:9090 --node-port=30000 --dry-run=client -o yaml | kubectl set selector --local -f - 'app=api' -o yaml | kubectl apply -f -
# OR
# kubectl expose deploy api-server --name=api-nodeport --type=NodePort --port=80 --target-port=9090
```

---

<a id="question-14"></a>
## Question 14 – Create Ingress Resource

### Problem Statement
Create Ingress `web-ingress`:
- Host: `web.example.com`
- Path: `/` (Prefix) -> `web-svc:8080`

### Setup Script
```bash
kubectl create svc clusterip web-svc --tcp=8080:80
```

### Solution
```bash
kubectl create ingress web-ingress --rule="web.example.com/=web-svc:8080" --path-type=Prefix
```

---

<a id="question-15"></a>
## Question 15 – Fix Ingress PathType

### Problem Statement
Fix invalid `pathType` in `/root/fix-ingress.yaml`.

### Setup Script
```bash
cat <<EOF > /root/fix-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata: 
  name: broken-ingress
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Invalid
        backend:
          service:
            name: svc
            port: 
              number: 80
EOF
```

### Solution
```bash
sed -i 's/pathType: Invalid/pathType: Prefix/' /root/fix-ingress.yaml
kubectl apply -f /root/fix-ingress.yaml
```

---

<a id="question-16"></a>
## Question 16 – Add Resource Requests and Limits to Pod

### Problem Statement
Create Pod `resource-pod` (`nginx`) with requests/limits set to exactly half of the `prod` namespace ResourceQuota.

### Setup Script
```bash
kubectl create ns prod
kubectl create quota prod-quota --hard=limits.cpu=2,limits.memory=4Gi -n prod
```

### Solution
```bash
# Check quota
kubectl describe quota -n prod
# Create Pod
kubectl run resource-pod --image=nginx -n prod --overrides='{"spec":{"containers":[{"name":"resource-pod","image":"nginx","resources":{"requests":{"cpu":"100m","memory":"128Mi"},"limits":{"cpu":"1","memory":"2Gi"}}}]}}'
```

---

<a id="question-17"></a>
## Question 17 – Fix labels to match existing NetworkPolicies

### Problem Statement
In namespace `default`, NetworkPolicies block traffic to `db-pod`.
Fix labels on `api-pod`, `monitor-pod`, and `db-pod` so that:
- `api-pod` can access `db-pod`
- `monitor-pod` can access `db-pod`

### Setup Script
```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: db-pod
  labels: {wrong: label}
spec:
  containers: [{name: db, image: nginx}]
---
apiVersion: v1
kind: Pod
metadata:
  name: api-pod
  labels: {wrong: label}
spec:
  containers: [{name: api, image: nginx}]
---
apiVersion: v1
kind: Pod
metadata:
  name: monitor-pod
  labels: {wrong: label}
spec:
  containers: [{name: monitor, image: nginx}]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: allow-frontend-to-backend}
spec:
  podSelector:
    matchLabels: {app: db}
  ingress:
  - from: [{podSelector: {matchLabels: {app: api}}}]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: allow-monitor-to-backend}
spec:
  podSelector:
    matchLabels: {app: db}
  ingress:
  - from: [{podSelector: {matchLabels: {role: monitor}}}]
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata: {name: deny-all-backend}
spec:
  podSelector: {matchLabels: {app: db}}
  policyTypes: [Ingress]
EOF
```

### Solution
```bash
# Inspect policies to find required labels
kubectl get netpol -o yaml

# Apply labels
kubectl label pod db-pod app=db --overwrite
kubectl label pod api-pod app=api --overwrite
kubectl label pod monitor-pod role=monitor --overwrite
```

---

<a id="question-18"></a>
## Question 18 – Canary Deployment

### Problem Statement
Implement a canary release:
- **Stable**: `nginx:1.14`, 3 replicas.
- **Canary**: `nginx:1.16`, 1 replica.
- Both must share label `app=web` and be served by the existing Service.

### Setup Script
```bash
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata: {name: web-stable}
spec:
  replicas: 1
  selector: {matchLabels: {app: web, version: stable}}
  template:
    metadata: {labels: {app: web, version: stable}}
    spec:
      containers: [{name: nginx, image: nginx:1.14}]
---
apiVersion: v1
kind: Service
metadata: {name: web-svc}
spec:
  selector: {app: web}
  ports: [{port: 80, targetPort: 80}]
EOF
```

### Solution
```bash
# 1. Scale Stable
kubectl scale deploy web-stable --replicas=3

# 2. Create Canary
kubectl create deploy web-canary --image=nginx:1.16 --replicas=1
kubectl label deploy web-canary app=web version=canary --overwrite

# 3. Verify
kubectl get endpoints web-svc
```


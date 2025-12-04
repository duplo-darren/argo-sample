# ArgoCD Learning Project

A simple project to learn ArgoCD GitOps with a frontend webserver and backend API.

## Project Structure

```
argo/
├── argocd/                    # ArgoCD Application manifests
│   ├── app-of-apps.yaml       # Parent app that manages other apps
│   ├── application-backend.yaml
│   ├── application-frontend.yaml
│   ├── namespace.yaml
│   └── project.yaml           # ArgoCD Project definition
├── base/
│   ├── backend/               # Backend API (http-echo)
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   └── kustomization.yaml
│   └── frontend/              # Frontend webserver (nginx)
│       ├── configmap.yaml
│       ├── deployment.yaml
│       ├── service.yaml
│       └── kustomization.yaml
└── README.md
```

## Prerequisites

- Kubernetes cluster (minikube, kind, k3s, etc.)
- kubectl configured
- ArgoCD installed in your cluster

## Quick Start

### 1. Install ArgoCD (if not already installed)

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 2. Access ArgoCD UI

```bash
# Get the initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward to access the UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Then open https://localhost:8080 (username: `admin`)

### 3. Push this repo to GitHub

```bash
git init
git add .
git commit -m "Initial ArgoCD demo project"
git remote add origin https://github.com/YOUR_USERNAME/argo.git
git push -u origin main
```

### 4. Update the repo URL

Edit these files and replace `YOUR_USERNAME` with your GitHub username:
- `argocd/application-backend.yaml`
- `argocd/application-frontend.yaml`
- `argocd/app-of-apps.yaml`

### 5. Deploy using App of Apps pattern

```bash
kubectl apply -f argocd/app-of-apps.yaml
```

Or deploy apps individually:

```bash
kubectl apply -f argocd/namespace.yaml
kubectl apply -f argocd/project.yaml
kubectl apply -f argocd/application-backend.yaml
kubectl apply -f argocd/application-frontend.yaml
```

### 6. Access the frontend

```bash
# If using minikube
minikube service frontend -n demo-app

# Or port-forward
kubectl port-forward svc/frontend -n demo-app 8081:80
```

## Learning Exercises

### Exercise 1: Manual Sync
1. Disable auto-sync in the ArgoCD UI
2. Change `replicas: 2` to `replicas: 3` in `base/backend/deployment.yaml`
3. Push the change to git
4. Watch ArgoCD detect the change (OutOfSync status)
5. Click "Sync" to apply the change

### Exercise 2: Self-Healing
1. Manually scale the backend: `kubectl scale deployment backend -n demo-app --replicas=1`
2. Watch ArgoCD automatically restore to the desired state (2 replicas)

### Exercise 3: Rollback
1. Make a change to the frontend ConfigMap
2. Push to git and let it sync
3. Use ArgoCD UI to rollback to a previous version

### Exercise 4: Add a new application
1. Create a new directory `base/redis/`
2. Add Redis deployment manifests
3. Create `argocd/application-redis.yaml`
4. Push and watch ArgoCD deploy it automatically

## Key Concepts

| Concept | Description |
|---------|-------------|
| **Application** | A group of Kubernetes resources defined in a Git repo |
| **Project** | A logical grouping of Applications with access controls |
| **Sync** | Process of applying Git manifests to the cluster |
| **Self-Heal** | Automatically revert manual changes to match Git |
| **Prune** | Delete resources removed from Git |
| **App of Apps** | Pattern where one Application manages other Applications |

## Useful Commands

```bash
# ArgoCD CLI (install: brew install argocd)
argocd login localhost:8080
argocd app list
argocd app get frontend
argocd app sync frontend
argocd app history frontend
argocd app rollback frontend <revision>

# Kubectl
kubectl get applications -n argocd
kubectl get all -n demo-app
```

## Troubleshooting

**App stuck in "Progressing":**
```bash
kubectl describe application frontend -n argocd
kubectl get events -n demo-app
```

**Sync failed:**
- Check the ArgoCD UI for detailed error messages
- Verify the Git repo URL and branch are correct
- Ensure the path to manifests exists

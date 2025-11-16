# GCP Required APIs Reference

This document lists all Google Cloud APIs that need to be enabled for the Terraform CI/CD template to work properly.

## Core Required APIs (Always Needed)

These APIs are required for basic Terraform functionality on GCP:

| API | Service Name | Purpose |
|-----|--------------|---------|
| Compute Engine API | `compute.googleapis.com` | Create and manage VMs, networks, firewalls |
| Cloud Resource Manager API | `cloudresourcemanager.googleapis.com` | Manage projects and resources |
| Identity and Access Management (IAM) API | `iam.googleapis.com` | Manage service accounts and permissions |
| Service Usage API | `serviceusage.googleapis.com` | Enable/disable APIs programmatically |
| Cloud Storage API | `storage-api.googleapis.com` | Storage operations |
| Cloud Storage | `storage.googleapis.com` | GCS bucket management |

## CI/CD Pipeline APIs

These APIs are required for the CI/CD pipeline to function:

| API | Service Name | Purpose |
|-----|--------------|---------|
| Cloud Build API | `cloudbuild.googleapis.com` | Run builds and CI/CD pipelines |
| Cloud Logging API | `logging.googleapis.com` | Store and query logs |
| Cloud Monitoring API | `monitoring.googleapis.com` | Monitor resources and performance |

## Optional APIs (Based on Your Resources)

Enable these based on what infrastructure you're deploying:

### Container & Kubernetes

| API | Service Name | Purpose |
|-----|--------------|---------|
| Kubernetes Engine API | `container.googleapis.com` | Manage GKE clusters |
| Artifact Registry API | `artifactregistry.googleapis.com` | Store container images |
| Container Registry API | `containerregistry.googleapis.com` | Legacy container registry |

### Database Services

| API | Service Name | Purpose |
|-----|--------------|---------|
| Cloud SQL Admin API | `sqladmin.googleapis.com` | Manage Cloud SQL databases |
| Cloud Firestore API | `firestore.googleapis.com` | NoSQL document database |
| Cloud Datastore API | `datastore.googleapis.com` | NoSQL database |
| Cloud Spanner API | `spanner.googleapis.com` | Distributed SQL database |

### Networking & Security

| API | Service Name | Purpose |
|-----|--------------|---------|
| Cloud DNS API | `dns.googleapis.com` | Manage DNS zones and records |
| Cloud Armor API | `compute.googleapis.com` | DDoS protection and WAF |
| VPC Access API | `vpcaccess.googleapis.com` | Serverless VPC Access |
| Certificate Manager API | `certificatemanager.googleapis.com` | SSL/TLS certificate management |

### Serverless & Functions

| API | Service Name | Purpose |
|-----|--------------|---------|
| Cloud Run API | `run.googleapis.com` | Deploy containerized apps |
| Cloud Functions API | `cloudfunctions.googleapis.com` | Deploy serverless functions |
| App Engine Admin API | `appengine.googleapis.com` | Deploy App Engine apps |

### Security & Secrets

| API | Service Name | Purpose |
|-----|--------------|---------|
| Secret Manager API | `secretmanager.googleapis.com` | Store and manage secrets |
| Cloud KMS API | `cloudkms.googleapis.com` | Encryption key management |
| Security Command Center API | `securitycenter.googleapis.com` | Security findings and alerts |

### Other Services

| API | Service Name | Purpose |
|-----|--------------|---------|
| Cloud Pub/Sub API | `pubsub.googleapis.com` | Messaging service |
| Cloud Scheduler API | `cloudscheduler.googleapis.com` | Cron job service |
| Cloud Tasks API | `cloudtasks.googleapis.com` | Asynchronous task execution |
| BigQuery API | `bigquery.googleapis.com` | Data warehouse |

## Enable All Core APIs (One Command)

```bash
# Set your project ID
export GCP_PROJECT_ID="your-project-id"

# Enable all core required APIs
gcloud services enable \
  compute.googleapis.com \
  cloudresourcemanager.googleapis.com \
  iam.googleapis.com \
  serviceusage.googleapis.com \
  storage-api.googleapis.com \
  storage.googleapis.com \
  cloudbuild.googleapis.com \
  logging.googleapis.com \
  monitoring.googleapis.com \
  --project=$GCP_PROJECT_ID
```

## Enable APIs Programmatically in Terraform

You can also enable APIs using Terraform:

```hcl
# terraform/apis.tf

locals {
  required_apis = [
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "serviceusage.googleapis.com",
    "storage-api.googleapis.com",
    "storage.googleapis.com",
    "cloudbuild.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ]
}

resource "google_project_service" "required_apis" {
  for_each = toset(local.required_apis)

  project = var.gcp_project_id
  service = each.value

  disable_on_destroy = false

  timeouts {
    create = "30m"
    update = "40m"
  }
}
```

## Check Enabled APIs

```bash
# List all enabled APIs
gcloud services list --enabled --project=$GCP_PROJECT_ID

# Check if specific API is enabled
gcloud services list --enabled \
  --filter="name:compute.googleapis.com" \
  --project=$GCP_PROJECT_ID

# List available APIs
gcloud services list --available --project=$GCP_PROJECT_ID
```

## Disable APIs (Use with Caution)

```bash
# Disable a specific API
gcloud services disable SERVICE_NAME.googleapis.com \
  --project=$GCP_PROJECT_ID

# Force disable (even if other services depend on it)
gcloud services disable SERVICE_NAME.googleapis.com \
  --force \
  --project=$GCP_PROJECT_ID
```

**Warning**: Disabling APIs can break existing resources and services. Always verify dependencies before disabling.

## API Quotas and Limits

Each API has its own quotas and limits. View them in the console:

1. Go to [APIs & Services > Quotas](https://console.cloud.google.com/apis/api/)
2. Select the API
3. View current usage and limits
4. Request quota increases if needed

### Common Quotas

| API | Default Quota | Request Increase |
|-----|---------------|------------------|
| Compute Engine | 24 CPUs per region | [Request](https://console.cloud.google.com/iam-admin/quotas) |
| Cloud Storage | 5 TB upload/day | [Request](https://console.cloud.google.com/iam-admin/quotas) |
| Cloud Build | 120 min/day free tier | Upgrade billing |

## Cost Implications

Enabling APIs is free, but **using** the services incurs costs:

### Free Tier Resources

- **Compute Engine**: 1 f1-micro instance per month (US regions)
- **Cloud Storage**: 5 GB storage per month
- **Cloud Build**: 120 build-minutes per day
- **Cloud Functions**: 2M invocations per month
- **Cloud Run**: 2M requests per month

### Cost Monitoring

```bash
# View billing information
gcloud billing projects describe $GCP_PROJECT_ID

# Set up billing budget alerts
gcloud billing budgets create \
  --billing-account=BILLING_ACCOUNT_ID \
  --display-name="Monthly Budget Alert" \
  --budget-amount=100USD \
  --threshold-rule=percent=50 \
  --threshold-rule=percent=90
```

## Troubleshooting

### "API is not enabled" Error

```bash
# Error message example:
# Error 403: Compute Engine API has not been used in project...

# Solution: Enable the API
gcloud services enable compute.googleapis.com --project=$GCP_PROJECT_ID
```

### "Permission Denied" Error

```bash
# Check your permissions
gcloud projects get-iam-policy $GCP_PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:user:YOUR_EMAIL"

# You need "serviceusage.services.enable" permission
# Usually granted by roles/editor or roles/owner
```

### API Takes Time to Enable

Some APIs take a few minutes to fully enable. Wait 2-5 minutes and try again.

```bash
# Wait for API to be fully enabled
while ! gcloud services list --enabled --filter="name:compute.googleapis.com" | grep -q compute; do
  echo "Waiting for API to be enabled..."
  sleep 5
done
echo "API is now enabled!"
```

## Best Practices

1. **Enable only what you need** - Each enabled API adds to your project's surface area
2. **Use infrastructure as code** - Enable APIs via Terraform for reproducibility
3. **Monitor usage** - Set up billing alerts to avoid unexpected costs
4. **Document dependencies** - Keep track of which APIs your infrastructure depends on
5. **Test in dev first** - Enable and test APIs in a development project before production

## API Enablement Checklist

Before starting your GCP Terraform project:

- [ ] Project created and billing enabled
- [ ] Core APIs enabled (compute, storage, IAM)
- [ ] CI/CD APIs enabled (Cloud Build, Logging)
- [ ] Service-specific APIs enabled (based on your needs)
- [ ] Billing alerts configured
- [ ] Quotas reviewed and increased if needed
- [ ] Service account permissions configured
- [ ] APIs documented in Terraform code

## Additional Resources

- [GCP API Library](https://console.cloud.google.com/apis/library)
- [Service Usage API Documentation](https://cloud.google.com/service-usage/docs)
- [GCP Pricing Calculator](https://cloud.google.com/products/calculator)
- [API Quotas Documentation](https://cloud.google.com/docs/quota)
- [Free Tier Details](https://cloud.google.com/free)

## Quick Reference Commands

```bash
# Enable API
gcloud services enable API_NAME.googleapis.com

# List enabled APIs
gcloud services list --enabled

# Check if API is enabled
gcloud services list --enabled --filter="name:API_NAME"

# Disable API
gcloud services disable API_NAME.googleapis.com

# Get API details
gcloud services describe API_NAME.googleapis.com
```

# Deployment Workflows - Quick Reference

## 🚀 Quick Start

### 1. Set Up GitHub Secrets (One-Time Setup)

```bash
# Navigate to: Repository Settings → Secrets and variables → Actions

# Add these secrets for each environment (dev, staging, prod):

# AWS Secrets
AWS_ROLE_ARN_dev
AWS_ROLE_ARN_staging
AWS_ROLE_ARN_prod
AWS_TFSTATE_BUCKET_dev
AWS_TFSTATE_BUCKET_staging
AWS_TFSTATE_BUCKET_prod
AWS_TFSTATE_LOCK_TABLE_dev
AWS_TFSTATE_LOCK_TABLE_staging
AWS_TFSTATE_LOCK_TABLE_prod

# GCP Secrets
GCP_WORKLOAD_IDENTITY_PROVIDER_dev
GCP_WORKLOAD_IDENTITY_PROVIDER_staging
GCP_WORKLOAD_IDENTITY_PROVIDER_prod
GCP_SERVICE_ACCOUNT_dev
GCP_SERVICE_ACCOUNT_staging
GCP_SERVICE_ACCOUNT_prod
GCP_PROJECT_ID_dev
GCP_PROJECT_ID_staging
GCP_PROJECT_ID_prod
GCP_TFSTATE_BUCKET_dev
GCP_TFSTATE_BUCKET_staging
GCP_TFSTATE_BUCKET_prod

# Optional
INFRACOST_API_KEY
SLACK_WEBHOOK_URL
```

### 2. Create GitHub Environments

```bash
# Navigate to: Repository Settings → Environments

# Create environments:
- dev (no protection)
- staging (optional: 1 reviewer)
- prod (required: 2 reviewers, main branch only)
```

### 3. Deploy!

```bash
# Push to branches:
git push origin develop    # → Deploys to staging
git push origin main       # → Deploys to production

# Or use manual trigger:
Actions → Select workflow → Run workflow
```

---

## 🎯 Common Commands

### Manual Deployment

```bash
# Via GitHub UI
1. Go to Actions tab
2. Select workflow (aws-deploy, gcp-deploy, or multi-cloud-deploy)
3. Click "Run workflow"
4. Select:
   - Environment (dev/staging/prod)
   - Action (deploy/plan-only/destroy)
   - Clouds (for multi-cloud: aws/gcp/all)
5. Click "Run workflow"
```

### Check Deployment Status

```bash
# Using GitHub CLI
gh run list --workflow=aws-deploy.yml --limit 5
gh run view <run-id>
gh run view <run-id> --log

# Check specific job
gh run view <run-id> --job=<job-id>
```

### View Terraform Plan

```bash
# In PR, plan is automatically commented
# Or download from workflow artifacts:
gh run download <run-id> -n tfplan-dev
```

---

## 🔧 Troubleshooting

### Issue: OIDC Authentication Failed

```bash
# Check:
1. Verify id-token: write permission in workflow
2. Check role trust policy allows your repository
3. Verify OIDC provider exists in AWS/GCP
4. Check role ARN is correct in GitHub secrets

# Test locally:
aws sts get-caller-identity
gcloud auth list
```

### Issue: Terraform State Locked

```bash
# Check lock status
aws dynamodb get-item \
  --table-name terraform-state-lock-dev \
  --key '{"LockID": {"S": "terraform-state-dev"}}'

# Force unlock (caution!)
terraform force-unlock <lock-id>
```

### Issue: Security Scan Failures

```bash
# Run locally first:
cd terraform/aws
tfsec .
checkov -d .

# Common fixes:
- Enable encryption: encryption = true
- Use HTTPS: protocol = "HTTPS"
- Restrict access: cidr_blocks = ["10.0.0.0/8"]
- Enable logging: logging { enabled = true }
```

### Issue: Workflow Timeout

```yaml
# Increase timeout in workflow file:
jobs:
  job-name:
    timeout-minutes: 60  # Default is 30
```

---

## 📊 Workflow Decision Tree

```
Push/PR Event
    │
    ├─ Branch = feature/* ──► Plan Only (No Deploy)
    │
    ├─ Branch = develop ────► Deploy to Staging
    │
    ├─ Branch = main ───────► Deploy to Production (with approval)
    │
    └─ Manual Trigger ──────► Custom (choose environment & action)

Security Scan
    │
    ├─ Pass ──► Continue to Plan
    │
    └─ Fail ──► Stop & Notify

Terraform Plan
    │
    ├─ No Changes ──► Skip Apply
    │
    ├─ Changes ─────► Generate Plan
    │                     │
    │                     ├─ PR ──► Comment on PR
    │                     │
    │                     └─ Push ──► Continue to Apply

Terraform Apply
    │
    ├─ Success ──► Deploy Application
    │
    └─ Fail ────► Rollback & Notify

Post-Deployment
    │
    ├─ Health Check Pass ──► Success
    │
    └─ Health Check Fail ──► Rollback
```

---

## 🔐 Security Checklist

- [ ] OIDC configured (no long-lived credentials)
- [ ] Separate IAM roles per environment
- [ ] Terraform state encrypted at rest
- [ ] State locking enabled
- [ ] GitHub environments configured with protection rules
- [ ] Security scanning enabled (tfsec, Checkov)
- [ ] Secret scanning enabled (Trufflehog)
- [ ] Production requires manual approval
- [ ] Audit logging enabled
- [ ] Cost monitoring configured

---

## 📋 Environment Mapping

| Branch      | Environment | Auto-Deploy | Approval Required |
|-------------|-------------|-------------|-------------------|
| feature/*   | dev         | No          | No                |
| develop     | staging     | Yes         | Optional          |
| release/*   | staging     | Yes         | Optional          |
| main        | prod        | Yes         | Required (2)      |

---

## 🎨 Notification Formats

### Slack Notification Example

```json
{
  "text": "✅ Deployment Successful",
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "✅ Deployment Successful\n*Environment:* prod\n*Region:* us-east-1\n*Triggered by:* @engineer"
      }
    }
  ]
}
```

### PR Comment Example

```markdown
#### Terraform Plan (AWS - staging)

**Environment**: staging
**Region**: us-west-2

Changes: 5 to add, 2 to change, 0 to destroy

Summary:
+ aws_instance.web
+ aws_security_group.web
~ aws_autoscaling_group.web (min_size: 2 → 3)
```

---

## 🚨 Emergency Procedures

### Rollback Production Deployment

```bash
# Option 1: Via GitHub UI
1. Go to Actions
2. Select workflow run
3. Click "Re-run failed jobs"
4. Or select "destroy" action in manual trigger

# Option 2: Via GitHub CLI
gh workflow run aws-deploy.yml \
  -f environment=prod \
  -f action=destroy

# Option 3: Manual Terraform
cd terraform/aws
terraform init -backend-config=...
terraform destroy -target=module.problematic_resource
```

### Force Unlock State

```bash
# Get lock ID from error message
# AWS
aws dynamodb get-item \
  --table-name terraform-state-lock-prod \
  --key '{"LockID": {"S": "..."}}' \
  --query 'Item.Info.S' \
  --output text

# GCP
gsutil cat gs://terraform-state-prod/.terraform.tflock.info

# Force unlock
terraform force-unlock <LOCK_ID>
```

### Disable Workflow Temporarily

```bash
# Via GitHub UI
1. Go to Actions → Workflows
2. Select workflow
3. Click "..." → "Disable workflow"

# Or add condition to workflow:
if: github.event_name != 'push' || vars.DEPLOYMENT_ENABLED == 'true'
```

---

## 📈 Monitoring & Metrics

### Key Metrics to Track

- **Deployment Frequency**: How often you deploy
- **Lead Time**: Time from commit to production
- **Change Failure Rate**: % of deployments causing issues
- **MTTR**: Mean time to recovery from failures
- **Security Findings**: Number of critical/high findings
- **Cost per Deployment**: Infrastructure costs

### View Metrics

```bash
# GitHub CLI
gh api /repos/:owner/:repo/actions/runs \
  --jq '.workflow_runs[] | select(.conclusion=="success") | .created_at'

# Or use GitHub Insights
Repository → Insights → Actions
```

---

## 🔗 Useful Links

### Internal
- [Full Documentation](./deployment-workflows-guide.md)
- [Terraform Modules](/terraform)
- [Environment Configs](/terraform/*/environments)

### External
- [GitHub Actions](https://docs.github.com/en/actions)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [tfsec Rules](https://aquasecurity.github.io/tfsec/)
- [Checkov Policies](https://www.checkov.io/5.Policy%20Index/all.html)

---

## 💡 Tips & Best Practices

1. **Always test in dev first**
   - Create PR from feature branch
   - Review plan output
   - Verify security scans pass

2. **Use meaningful commit messages**
   - Conventional Commits format
   - Link to tickets/issues
   - Explain why, not what

3. **Keep environments in sync**
   - Promote code through environments
   - Don't skip staging
   - Test everything in staging first

4. **Monitor costs**
   - Review Infracost reports
   - Set up budget alerts
   - Clean up unused resources

5. **Document decisions**
   - Use PR descriptions
   - Update terraform comments
   - Maintain changelog

6. **Review security findings**
   - Don't ignore warnings
   - Fix critical/high issues immediately
   - Plan remediation for medium/low

7. **Regular maintenance**
   - Update dependencies monthly
   - Rotate credentials quarterly
   - Review IAM permissions quarterly
   - Test disaster recovery annually

---

## 📞 Support

### Issue Priority Levels

**P0 - Critical (Production Down)**
- Contact: On-call engineer
- Response: Immediate
- Action: Rollback + hotfix

**P1 - High (Production Degraded)**
- Contact: Team lead
- Response: < 1 hour
- Action: Emergency patch

**P2 - Medium (Staging Issues)**
- Contact: DevOps team
- Response: < 4 hours
- Action: Fix in next deployment

**P3 - Low (Dev/Questions)**
- Contact: Team chat
- Response: < 1 business day
- Action: Schedule fix

### Contact Information

- **DevOps Team**: #devops-support
- **On-Call**: pagerduty.com/...
- **Documentation**: wiki.company.com/...
- **Incident Management**: incident.io/...

---

**Last Updated:** 2025-11-06
**Version:** 1.0.0

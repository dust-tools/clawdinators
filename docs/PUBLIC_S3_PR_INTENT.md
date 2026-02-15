# Public S3: PR intent artifacts

Goal: publish a **public-safe** subtree from shared memory (`/memory`) to an **anonymous public S3 bucket** so maintainers can quickly list + pull artifacts.

## Infra (OpenTofu)

The AWS OpenTofu stack (`infra/opentofu/aws`) provisions a public bucket:
- anonymous `ListBucket`
- anonymous `GetObject`
- CLAWDINATOR instance role can `PutObject` (no deletes)

After `tofu apply`, get the bucket name:

```sh
tofu output -raw pr_intent_bucket_name
```

## On-host publishing (NixOS)

Enable the publisher timer on CLAWDINATOR hosts:

```nix
services.clawdinator.publicS3 = {
  enable = true;
  bucket = "<tofu output pr_intent_bucket_name>";
  # default sourceDir: "${config.services.clawdinator.memoryDir}/pr-intent"
};
```

Publishing behavior:
- uploads **new + edited** files
- does **not** delete objects from S3
- runs on a systemd timer (`services.clawdinator.publicS3.schedule`, default every 10 min)

Note: current PR intent skill output path is `/memory/pr-intent/...` (on EFS). That matches the default `sourceDir`.

## Maintainer download (no AWS creds)

List:

```sh
aws s3 ls s3://<bucket>/ --no-sign-request
```

Pull everything:

```sh
aws s3 sync s3://<bucket>/ ./pr-intent --no-sign-request
```

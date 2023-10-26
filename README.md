# Example of a Hyper-V enabled Windows 11 VM on Azure

### Requires:
1. An Azure subscription
2. RBAC to create resources
3. Az PowerShell
4. Az CLI

### Usage:
Deploy by running: `./deploy.ps1` and expect to be prompted to provide desired vm password.

### What to expect:
1. Deployment time ~10-20min.
2. Once finished you will have a virtual machine running Windows 11 with Hyper-V installed accessible by bastion with a local account.
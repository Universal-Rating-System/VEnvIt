---
name: HotFix Report
about: An urgent, critical fix applied directly to the live environment, often bypassing regular development cycles.
title: '[HotFix]: '
labels:
  - hotfix
---

**What happened**:

**What you expected to happen**:

**Minimal Complete Verifiable Example**:

<!-- See http://matthewrocklin.com/blog/work/2018/02/28/minimal-bug-reports or https://stackoverflow.com/help/mcve for an example -->

```python
# Put your MCVE code here
```

**Anything else we need to know?**:

**Why is this a hotfix and not a bugfix i.e. describe the impact on the production system.**:

**Environment**:

- gitit version:
- Python version:
- Operating System:
- Install method (pip, source):

**Ticket Nr**

<!--Will be provided by owner -->

**New Release Checks:**
Only once all the checks below are completed should there be a new release:

- [ ] Commented code is not useful anymore are removed.
- [ ] Commented GitHub Workflows scripts for testing purposes are restored.
- [ ] Functions/methods/variables in modules are in alphabetical order (if possible).
- [ ] Pre-Commit successful
- [ ] CI successful
- [ ] CodeCov above 99% or justifiably less
- [ ] Badges are correct.
- [ ] Changed current branch to `master`
- [ ] Deleted the development branch

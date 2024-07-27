---
name: BugFix Report
about: An error or defect causing incorrect or unexpected behavior; typically fixed in regular development cycles.
title: '[BugFix]: '
labels:
  - bugfix
---

**Describe the problem**:

**Command executed**:

```bash

```

**List the source code file(s) and line number where you think the error is (if known)**

**Minimal Complete Verifiable Example**:

<!-- See http://matthewrocklin.com/blog/work/2018/02/28/minimal-bug-reports or https://stackoverflow.com/help/mcve for an example -->

```python
# Put your MCVE code here
```

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

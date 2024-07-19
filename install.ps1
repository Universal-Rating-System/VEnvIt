Write-Information "Running D:\Dropbox\Projects\BEE\venvit\install.ps1..." -ForegroundColor Yellow
pip install --upgrade --force --no-cache-dir black
pip install --upgrade --force --no-cache-dir flake8
pip install --upgrade --force --no-cache-dir pre-commit
pre-commit install
pre-commit autoupdate

et -e

set -a
source .env
set +a

bash ./scripts/generate_ssh_key.sh

bash ./scripts/install_python.sh

bash ./scripts/install_terraform.sh

python -m venv env
source env/bin/activate
pip install -r requirements.txt

env/bin/python main.py

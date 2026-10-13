import os
import json
import shutil
import subprocess


def setup_hosts(hosts, BASE_DIR, PROJECT_NAME):
    ANSIBLE_DIR = BASE_DIR / "ansible"

    ssh_key = BASE_DIR / "keys" / f"{PROJECT_NAME}-key.pem"
    if not ssh_key.is_file():
        raise FileNotFoundError(f"SSH key not found: {ssh_key}")
    if not shutil.which("ansible-playbook"):
        raise RuntimeError(
            "ansible-playbook is unavailable. "
            "Run this orchestration in Linux or WSL with Ansible installed."
        )
    public_ips = [
        *hosts["application"]["public_ips"].values(),
        *hosts["database"]["public_ips"].values(),
        *hosts["redis"]["public_ips"].values(),
        hosts["monitoring"]["public_ip"],
    ]
    inventory = ",".join(public_ips) + ","
    ansible_env = os.environ.copy()
    ansible_env["ANSIBLE_CONFIG"] = str(ANSIBLE_DIR / "ansible.cfg")
    print(f"Installing Docker on {len(public_ips)} hosts...")
    subprocess.run(
        [
            "ansible-playbook",
            "-i",
            inventory,
            "--private-key",
            str(ssh_key),
            "--user",
            "ubuntu",
            "--extra-vars",
            json.dumps({"project_name": PROJECT_NAME}),
            str(ANSIBLE_DIR / "playbooks" / "setup.yml"),
        ],
        cwd=ANSIBLE_DIR,
        env=ansible_env,
        check=True,
    )

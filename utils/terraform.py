import json
import subprocess


def run_terraform(*arguments, capture_output=False, INFRA_DIR):
    return subprocess.run(
        [
            "terraform",
            f"-chdir={INFRA_DIR}",
            *arguments,
        ],
        check=True,
        capture_output=capture_output,
        text=True,
    )


def get_hosts(INFRA_DIR):
    result = run_terraform(
        "output", "-json", capture_output=True, INFRA_DIR=INFRA_DIR)
    outputs = json.loads(result.stdout)

    def output_value(name):
        if name not in outputs:
            raise ValueError(f"Missing Terraform output: {name}")

        return outputs[name]["value"]

    hosts = {
        "application": {
            "public_ips": output_value("app_public_ips"),
            "private_ips": output_value("app_private_ips"),
        },
        "database": {
            "public_ips": output_value("database_public_ips"),
            "private_ips": output_value("database_private_ips"),
        },
        "monitoring": {
            "public_ip": output_value("monitoring_public_ip"),
            "private_ip": output_value("monitoring_private_ip"),
        },
    }

    for group in ("application", "database"):
        public_ips = hosts[group]["public_ips"]
        private_ips = hosts[group]["private_ips"]

        if not public_ips or public_ips.keys() != private_ips.keys():
            raise ValueError(f"Incomplete Terraform host outputs: {group}")

        if not all(public_ips.values()) or not all(private_ips.values()):
            raise ValueError(f"Missing IP addresses for {group} hosts.")

    if not all(hosts["monitoring"].values()):
        raise ValueError("Missing monitoring IP addresses.")

    return hosts

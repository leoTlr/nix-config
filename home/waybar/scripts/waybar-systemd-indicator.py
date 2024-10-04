import subprocess
import json
from dataclasses import dataclass


@dataclass
class UnitInfo:
    system: list
    user: list

    def count_total(self):
        return len(self.system) + len(self.user)

    def count_system(self):
        return len(self.system)

    def count_user(self):
        return len(self.user)

    def _tooltip_units(self, kind):
        return f'Failed {kind} units:\n{str.join("\n", getattr(self, kind))}'

    def tooltip(self):
        if self.count_system() > 0 and self.count_user() > 0:
            return (
                self._tooltip_units("system")
                + "\n\n"
                + self._tooltip_units("user")
            )
        elif self.count_system() == 0 and self.count_user() > 0:
            return self._tooltip_units("user")
        elif self.count_system() > 0 and self.count_user() == 0:
            return self._tooltip_units("system")
        else:
            return "All units OK"

    def __str__(self):
        # returns json with fields that waybar requires
        degraded = True if self.count_total() > 0 else False
        return json.dumps({
            "text": f'{self.count_total()}{"✗" if degraded else "✓"}',
            "tooltip": self.tooltip(),
            "class": "degraded" if degraded else "ok"
        })


def get_failed_units():
    systemctl_args = [
        "systemctl", "--plain", "--no-legend", "list-units",
        "--state=failed", "--type", "service",
        "--output", "json",
    ]

    cmd = lambda args: subprocess.run(args, capture_output=True, text=True)  # noqa: E731,E501

    system = json.loads(cmd(systemctl_args).stdout)
    user = json.loads(cmd(systemctl_args + ["--user"]).stdout)

    return (
        [unit["unit"] for unit in system],
        [unit["unit"] for unit in user]
    )


def main():
    print(UnitInfo(*get_failed_units()))


if __name__ == "__main__":
    main()

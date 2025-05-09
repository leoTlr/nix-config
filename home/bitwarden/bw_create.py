#!/usr/bin/env python3
# min py 3.10 for match statement and type union with |

import argparse as ap
import logging
from os import environ
from dataclasses import dataclass
from abc import ABC, abstractmethod
from json import dumps, loads
from subprocess import run, PIPE
from sys import exit

logger = logging.getLogger(__name__)
logging.basicConfig(format="{levelname}: {message}", style="{")


@dataclass
class BwEntity(ABC):
    def as_bw_json(self):
        # bitwarden cli requires a complete json template for item creation and fails otherwise
        # getting a template requires an unlocked vault
        template = loads(run_cmd(["bw", "get", "template", self._bw_template_id]))
        logger.debug(f"{self.__class__.__name__} template: {template}")
        template_patched = template | self._template_patch()
        logger.debug(f"{self.__class__.__name__} patched template: {template_patched}")
        return template_patched

    @property
    @abstractmethod
    def _bw_template_id(self) -> str: ...

    @abstractmethod
    def _template_patch(self) -> dict: ...


@dataclass
class BwUri(BwEntity):
    _bw_template_id = "item.login.uri"

    uri: str

    def _template_patch(self) -> dict:
        return {"uri": self.uri}


@dataclass
class BwLogin(BwEntity):
    _bw_template_id = "item.login"

    username: str
    password: str
    uri: BwUri | None = None

    def _template_patch(self) -> dict:
        return {
            "username": self.username,
            "password": self.password,
            "totp": "",  # template puts undesired stuff in here
            "uris": [self.uri.as_bw_json()] if self.uri else [],
        }


@dataclass
class BwItem(BwEntity):
    _bw_template_id = "item"

    name: str
    login: BwLogin

    def _template_patch(self) -> dict:
        return {
            "name": self.name,
            "login": self.login.as_bw_json(),
            "notes": "",  # tempate puts undesired stuff in here
        }


def parse_args() -> ap.Namespace:
    parser = ap.ArgumentParser(
        description="wrapper around bitwarden cli to create login entries because official cli sucks for that"
    )
    parser.add_argument("name", type=str, help="bitwarden item.name")
    parser.add_argument("username", type=str, help="bitwarden item.login.username")
    parser.add_argument("--uri", default=None, help="bitwarden item.login.uris[].uri")
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="print resulting item json without creating it",
    )
    parser.add_argument(
        "-v", "--verbosity", action="count", default=1, help="levels 0,1,2"
    )
    pw_group = parser.add_argument_group("password", "bitwarden item.login.password")
    pw_choice = pw_group.add_mutually_exclusive_group(required=True)
    pw_choice.add_argument("-p", "--password", metavar="PW", help="set pw per cli arg")
    pw_choice.add_argument("--ask", action="store_true", help="ask for pw on stdin")
    pw_choice.add_argument(
        "--generate", type=int, metavar="length", help="generate pw of length"
    )
    return parser.parse_args()


def run_cmd(cmd: str | list[str], stdin: str | None = None) -> str:
    args = {
        "encoding": "utf-8",
        "check": True,
        "input": stdin,
        "stdout": PIPE,
        "stderr": None,
    }
    logger.info(f"running command: {cmd}")
    result = run(cmd, **args)
    logger.debug(f"command result: {result}")
    return result.stdout


def retrieve_password(args: ap.Namespace) -> str:
    match args:
        case ap.Namespace(password=pw) if pw is not None:
            logger.info("using cli-provided password for item")
            return pw
        case ap.Namespace(ask=True):
            logger.info("requesting item password from user")
            return run_cmd("systemd-ask-password")[:-1]
        case ap.Namespace(generate=length) if length >= 1:
            logger.info(f"generating item password of length {length}")
            return run_cmd(["bw", "generate", "-lusn", "--length", str(length)])
        case ap.Namespace(generate=length) if length < 1:
            raise ValueError("length must be >= 1")
        case _:
            raise RuntimeError("illegal state")


def set_log_level(verbosity: int):
    match verbosity:
        case n if n <= 0:
            logger.setLevel(logging.FATAL)
        case n if n == 1:
            logger.setLevel(logging.INFO)
        case n if n >= 2:
            logger.setLevel(logging.DEBUG)
        case _:
            raise RuntimeError("illegal state")


if __name__ == "__main__":
    args = parse_args()
    logger.debug(f"cli args: {args}")
    set_log_level(args.verbosity)

    if "BW_SESSION" not in environ:
        logger.info("Attempting vault unlock")
        environ["BW_SESSION"] = run_cmd(["bw", "unlock", "--raw"])

    password = retrieve_password(args)
    entry = BwItem(
        args.name,
        BwLogin(args.username, password, BwUri(args.uri) if args.uri else None),
    )

    if args.dry_run:
        print(dumps(entry.as_bw_json(), indent=4))
        exit(0)

    entry_encoded = run_cmd(["bw", "encode"], stdin=dumps(entry.as_bw_json()))
    run_cmd(["bw", "create", "item"], stdin=entry_encoded)
    run_cmd(["bw", "sync"])
    logger.info(f'Successfully created item "{entry.name}"')

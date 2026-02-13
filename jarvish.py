#!/usr/bin/env python3
"""Jarvish: a tiny personal command-line assistant."""

from __future__ import annotations

import json
import random
from datetime import datetime
from pathlib import Path

PROFILE_PATH = Path.home() / ".jarvish_profile.json"

MOTIVATION_LINES = [
    "You’ve got this. One clear step at a time.",
    "Progress beats perfection. Keep moving.",
    "Focus on the next action, not the whole mountain.",
    "Small consistent wins build unstoppable momentum.",
]


class Jarvish:
    def __init__(self, profile_path: Path = PROFILE_PATH) -> None:
        self.profile_path = profile_path
        self.profile = self._load_profile()

    def _default_profile(self) -> dict[str, str]:
        return {
            "name": "Boss",
            "assistant_name": "Jarvish",
            "daily_goal": "Do one meaningful task today",
        }

    def _load_profile(self) -> dict[str, str]:
        if not self.profile_path.exists():
            return self._default_profile()
        try:
            return json.loads(self.profile_path.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            return self._default_profile()

    def save_profile(self) -> None:
        self.profile_path.write_text(json.dumps(self.profile, indent=2), encoding="utf-8")

    def onboarding(self) -> None:
        print("=== Personal Jarvish Setup ===")
        name = input("What should I call you? ").strip() or "Boss"
        assistant_name = input("What should my name be? ").strip() or "Jarvish"
        daily_goal = input("What's your current daily goal? ").strip() or "Do one meaningful task today"

        self.profile.update(
            {
                "name": name,
                "assistant_name": assistant_name,
                "daily_goal": daily_goal,
            }
        )
        self.save_profile()
        print(f"Done. {assistant_name} is now personalized for you, {name}.")

    def greet(self) -> None:
        now = datetime.now().strftime("%H:%M")
        print(f"{self.profile['assistant_name']}: Good day, {self.profile['name']}. It's {now}.")
        print(f"{self.profile['assistant_name']}: Reminder — {self.profile['daily_goal']}")

    def show_help(self) -> None:
        print(
            """
Commands:
  help       Show this list
  status     Show date/time and goal
  motivate   Hear a motivation line
  goal       Update your daily goal
  setup      Re-run personalization
  quit       Exit Jarvish
""".strip()
        )

    def status(self) -> None:
        print(f"Date: {datetime.now().strftime('%A, %d %B %Y')}")
        print(f"Time: {datetime.now().strftime('%H:%M:%S')}")
        print(f"Goal: {self.profile['daily_goal']}")

    def motivate(self) -> None:
        print(f"{self.profile['assistant_name']}: {random.choice(MOTIVATION_LINES)}")

    def update_goal(self) -> None:
        new_goal = input("Enter your new daily goal: ").strip()
        if not new_goal:
            print("Goal unchanged.")
            return
        self.profile["daily_goal"] = new_goal
        self.save_profile()
        print("Goal updated.")

    def run(self) -> None:
        if not self.profile_path.exists():
            self.onboarding()
        self.greet()
        self.show_help()

        while True:
            command = input("\nYou> ").strip().lower()
            if command == "help":
                self.show_help()
            elif command == "status":
                self.status()
            elif command == "motivate":
                self.motivate()
            elif command == "goal":
                self.update_goal()
            elif command == "setup":
                self.onboarding()
            elif command in {"quit", "exit"}:
                print(f"{self.profile['assistant_name']}: Until next time.")
                break
            elif not command:
                continue
            else:
                print("Unknown command. Type 'help' to see available commands.")


if __name__ == "__main__":
    Jarvish().run()

import re
from typing import List


def analyze_urls(message: str) -> List[str]:
    results = []
    urls = re.findall(r"https?://\S+", message)

    if urls:
        results.append(f"Found {len(urls)} URL(s)")

        for url in urls:
            if len(url) > 40:
                results.append("Long suspicious URL detected")

            if "bit.ly" in url or "tinyurl" in url:
                results.append("URL shortener detected")

    return results


def explain_message(message: str) -> List[str]:
    reasons = []

    categories = {
        "Urgency": ["urgent", "immediately", "now", "act"],
        "Financial": ["money", "bank", "payment", "cash"],
        "Account manipulation": ["verify", "password", "login", "account"],
        "Reward scam": ["winner", "free", "claim", "prize"],
    }

    lower = message.lower()

    for category, words in categories.items():
        for word in words:
            if word in lower:
                reasons.append(f"{category} indicator detected: {word}")

    reasons.extend(analyze_urls(message))
    return reasons

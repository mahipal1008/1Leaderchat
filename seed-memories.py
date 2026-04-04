"""
Seed Claude.ai memories into LibreChat.
Run this script to import your Claude.ai memory into your LibreChat instance.

Usage:
    python seed-memories.py <email> <password>

Example:
    python seed-memories.py rajsfbodh@gmail.com MyPassword123
"""
import sys
import json
import requests

BASE_URL = "https://librechat-e2gv.onrender.com"

# Your Claude.ai memories broken into individual facts
MEMORIES = {
    "user_name": "Mahipal",
    "user_education": "B.Tech CSE student, 6th semester",
    "user_location": "Bhagalpur, India",
    "user_entity": "Solo founder of EduCard AI Technologies",
    "user_founder_name": "Ravi Roy (legal name Lashman Dass)",
    "user_contact": "mahipal@educard-ai.indevs.in",
    "user_os": "Windows",
    "user_interests": "Full-stack development, AI/ML tooling, compiler design, consumer electronics, fintech, EV tech, AI-powered apps",
    "project_educard": "EduCard AI (educard-ai.indevs.in) - AI-powered adaptive study platform with flashcards, quizzes, learning paths. Stack: Next.js, Node.js, PostgreSQL, Redis. GitHub: mahipal1008/educard-ai",
    "project_dinesync": "DineSync (github.com/mahipal1008/DineSync) - Multi-tenant hostel mess management. 126 API endpoints, 35 DB tables, 124 frontend pages. Stack: Next.js 15, Express 5, PostgreSQL, Redis, Docker, TypeScript, Socket.IO",
    "project_monitorserver": "MonitorServer / Argus (monitorserver.indevs.in) - Real-time server monitoring for indie devs. Stack: Node.js, WebSockets, Bash agent. Team: NightsWatch for CS 331 Software Engineering Lab",
    "cloud_aws": "AWS Activate Portfolio tier credits (Org ID 8o5G6, Account ID 610489687271). AISPL payment resolved via Net 30 invoicing. Bedrock access in us-east-1.",
    "cloud_other": "Alibaba Cloud AI Catalyst Program approved. Make Startup Program (480K credits, 12 months). HubSpot for Startups. YC Startup School enrolled.",
    "infra_email": "Business email via LarkSuite for monitorserver.in (support@, admin@, noreply@, founder@). DNS via Stackryze/Cloudflare for indevs.in domain.",
    "preference_language": "Always respond in English only, even if user writes in Hindi or another language",
    "preference_accuracy": "Before stating any factual claim, always search and verify from official sources. Label anything unconfirmed as 'unverified'. Include citations or direct links.",
}


def main():
    if len(sys.argv) < 3:
        print("Usage: python seed-memories.py <email> <password>")
        sys.exit(1)

    email, password = sys.argv[1], sys.argv[2]

    # Login
    print(f"Logging in as {email}...")
    resp = requests.post(f"{BASE_URL}/api/auth/login", json={"email": email, "password": password})
    if resp.status_code != 200:
        print(f"Login failed: {resp.text}")
        sys.exit(1)

    token = resp.json()["token"]
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    print("Login successful!")

    # Check existing memories
    resp = requests.get(f"{BASE_URL}/api/memories", headers=headers)
    existing = resp.json()
    print(f"Existing memories: {len(existing['memories'])}")

    # Seed memories
    created = 0
    updated = 0
    for key, value in MEMORIES.items():
        resp = requests.post(f"{BASE_URL}/api/memories", headers=headers, json={"key": key, "value": value})
        if resp.status_code == 200:
            data = resp.json()
            if data.get("created"):
                created += 1
                print(f"  + {key}")
            else:
                updated += 1
                print(f"  ~ {key} (updated)")
        else:
            print(f"  ! {key} FAILED: {resp.text[:100]}")

    print(f"\nDone! Created: {created}, Updated: {updated}")

    # Verify
    resp = requests.get(f"{BASE_URL}/api/memories", headers=headers)
    final = resp.json()
    print(f"Total memories now: {len(final['memories'])}")
    print(f"Token usage: {final['totalTokens']}/{final['tokenLimit']} ({final['usagePercentage']}%)")


if __name__ == "__main__":
    main()

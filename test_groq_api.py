#!/usr/bin/env python3
"""
CalorieWala — Groq API Key & Vision Model Tester
Run: python test_groq_api.py
Requires: pip install requests
"""

import os
import sys
import json
import base64
import requests

# ── Load API key from .env ─────────────────────────────────────────────────────
def load_env(filepath=".env"):
    env = {}
    try:
        with open(filepath) as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#") and "=" in line:
                    k, v = line.split("=", 1)
                    env[k.strip()] = v.strip()
    except FileNotFoundError:
        print(f"⚠  .env file not found at: {os.path.abspath(filepath)}")
    return env

env = load_env()
API_KEY      = env.get("GROQ_API_KEY", "")
BASE_URL     = env.get("GROQ_BASE_URL", "https://api.groq.com/openai/v1")
VISION_MODEL = env.get("VISION_MODEL",  "meta-llama/llama-4-scout-17b-16e-instruct")
TEXT_MODEL   = env.get("TEXT_MODEL",    "llama-3.3-70b-versatile")

HEADERS = {
    "Authorization": f"Bearer {API_KEY}",
    "Content-Type":  "application/json",
}

def sep(title=""):
    print("\n" + "─" * 60)
    if title:
        print(f"  {title}")
        print("─" * 60)

# ── Test 1: API Key validity ────────────────────────────────────────────────────
def test_api_key():
    sep("TEST 1 — API Key Validity")
    if not API_KEY:
        print("❌ GROQ_API_KEY is empty in .env!")
        return False

    print(f"   Key prefix: {API_KEY[:12]}...")
    resp = requests.get(f"{BASE_URL}/models", headers=HEADERS, timeout=10)

    if resp.status_code == 200:
        models = [m["id"] for m in resp.json().get("data", [])]
        print(f"✅ API key is VALID")
        print(f"   Available models ({len(models)} total):")
        for m in models[:10]:
            print(f"     • {m}")
        if len(models) > 10:
            print(f"     ... and {len(models)-10} more")
        return models
    elif resp.status_code == 401:
        print("❌ API key is INVALID or expired (401)")
        print(f"   Response: {resp.text[:300]}")
    else:
        print(f"❌ Unexpected status {resp.status_code}")
        print(f"   Response: {resp.text[:300]}")
    return False

# ── Test 2: Text model ──────────────────────────────────────────────────────────
def test_text_model():
    sep(f"TEST 2 — Text Model: {TEXT_MODEL}")
    payload = {
        "model": TEXT_MODEL,
        "messages": [
            {"role": "system", "content": "You are a food nutritionist. Respond with JSON only."},
            {"role": "user",   "content": 'List the nutrition for "1 roti, 1 katori dal". Respond: {"total_calories":X,"protein_g":X,"carbs_g":X,"fat_g":X,"health_note":"...","disclaimer":"..."}'}
        ],
        "max_tokens": 200,
        "temperature": 0.2,
        "response_format": {"type": "json_object"}
    }
    try:
        resp = requests.post(f"{BASE_URL}/chat/completions", headers=HEADERS, json=payload, timeout=30)
        if resp.status_code == 200:
            content = resp.json()["choices"][0]["message"]["content"]
            data    = json.loads(content)
            print(f"✅ Text model WORKS")
            print(f"   Calories: {data.get('total_calories')} kcal")
            print(f"   Protein:  {data.get('protein_g')} g")
            print(f"   Carbs:    {data.get('carbs_g')} g")
            print(f"   Fat:      {data.get('fat_g')} g")
            print(f"   Note:     {data.get('health_note', '')[:80]}")
            return True
        else:
            print(f"❌ Text model FAILED ({resp.status_code})")
            print(f"   Response: {resp.text[:400]}")
    except Exception as e:
        print(f"❌ Exception: {e}")
    return False

# ── Test 3: Vision model ────────────────────────────────────────────────────────
def test_vision_model():
    sep(f"TEST 3 — Vision Model: {VISION_MODEL}")

    # Create a tiny 1x1 red JPEG in base64 so we don't need a real image file
    tiny_jpeg_b64 = (
        "/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8U"
        "HRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/wAALCAABAAEBAREA"
        "Ax8A/8QAFAABAAAAAAAAAAAAAAAAAAAACf/EABQQAQAAAAAAAAAAAAAAAAAAAAD/2gAIAQEC"
        "AD8AVQAP/8QAFBABAAAAAAAAAAAAAAAAAAAAAP/aAAgBAQABP8BAAAP/2Q=="
    )

    payload = {
        "model": VISION_MODEL,
        "messages": [
            {
                "role": "user",
                "content": [
                    {"type": "text",      "text": "What food do you see in this image? Respond with JSON: {\"items\":[{\"name\":\"food\",\"portion\":\"unknown\",\"confidence\":\"low\"}]}"},
                    {"type": "image_url", "image_url": {"url": f"data:image/jpeg;base64,{tiny_jpeg_b64}"}},
                ],
            }
        ],
        "max_tokens": 200,
        "temperature": 0.3,
    }
    try:
        resp = requests.post(f"{BASE_URL}/chat/completions", headers=HEADERS, json=payload, timeout=30)
        if resp.status_code == 200:
            content = resp.json()["choices"][0]["message"]["content"]
            print(f"✅ Vision model WORKS")
            print(f"   Response: {content[:200]}")
            return True
        else:
            body = resp.json() if resp.headers.get("content-type","").startswith("application/json") else resp.text
            print(f"❌ Vision model FAILED ({resp.status_code})")
            if isinstance(body, dict):
                err = body.get("error", {})
                print(f"   Error type: {err.get('type','')}")
                print(f"   Message:    {err.get('message','')[:300]}")

                # Suggest fix if model is wrong
                if "model" in str(err).lower() or resp.status_code == 404:
                    print("\n   💡 FIX: The vision model name is wrong for Groq.")
                    print("   Update VISION_MODEL in your .env to:")
                    print("   VISION_MODEL=meta-llama/llama-4-scout-17b-16e-instruct")
                    print("   OR if that model is unavailable, try:")
                    print("   VISION_MODEL=llama-3.2-11b-vision-preview")
            else:
                print(f"   Response: {str(body)[:300]}")
    except Exception as e:
        print(f"❌ Exception: {e}")
    return False

# ── Test 4: Check .env file ────────────────────────────────────────────────────
def show_config():
    sep("CONFIG SUMMARY")
    print(f"   GROQ_API_KEY  : {API_KEY[:12]}{'*'*20 if len(API_KEY)>12 else '(EMPTY)'}")
    print(f"   GROQ_BASE_URL : {BASE_URL}")
    print(f"   VISION_MODEL  : {VISION_MODEL}")
    print(f"   TEXT_MODEL    : {TEXT_MODEL}")

# ── Main ────────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    print("=" * 60)
    print("  CalorieWala — Groq API Tester")
    print("=" * 60)

    show_config()

    models = test_api_key()
    if models:
        text_ok   = test_text_model()
        vision_ok = test_vision_model()

        sep("SUMMARY")
        print(f"  API Key   : {'✅ Valid' if models else '❌ Invalid'}")
        print(f"  Text API  : {'✅ Working' if text_ok else '❌ Failed'}")
        print(f"  Vision API: {'✅ Working' if vision_ok else '❌ Failed'}")

        if not vision_ok:
            print("\n  🔧 NEXT STEPS:")
            print("  1. Check which models support vision on Groq:")
            print("     https://console.groq.com/docs/openai#vision")
            print("  2. Update VISION_MODEL in .env")
            print("  3. Supported vision models (as of 2025):")
            print("     • meta-llama/llama-4-scout-17b-16e-instruct")
            print("     • meta-llama/llama-4-maverick-17b-128e-instruct")
            print("     • llama-3.2-11b-vision-preview")
            print("     • llama-3.2-90b-vision-preview")
    else:
        sep("SUMMARY")
        print("  ❌ Cannot proceed — API key is invalid")
        print("  Get a free key at: https://console.groq.com/keys")

    sep()

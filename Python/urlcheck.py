#Author Piotr Tarnawski
#angrysysops.com
# X: -> @TheTechWorldPod


import requests


def normalize_url(raw_url: str) -> str:
    """Make sure the URL has a protocol."""
    url = raw_url.strip()

    if not url.startswith(("http://", "https://")):
        # Default to HTTPS if user is lazy (they always are)
        url = "https://" + url

    return url


def check_status(raw_url: str) -> None:
    """Check the HTTP status of a given URL."""
    url = normalize_url(raw_url)
    print(f"\nChecking: {url}")

    try:
        # 3 second timeout so we don't sit forever
        response = requests.get(url, timeout=3)
        code = response.status_code
        print(f"Status code: {code}")

        if 200 <= code < 300:
            print("✅ Site is UP (2xx success)")
        elif 300 <= code < 400:
            print("➡️ Redirected (3xx)")
        elif 400 <= code < 500:
            print("❌ Client error (4xx) – check the URL.")
        else:
            print("💥 Server error or unexpected response.")
    except requests.exceptions.Timeout:
        print("⏰ Request timed out after 3 seconds.")
    except requests.exceptions.RequestException as e:
        print(f"⚠️ Could not reach the site: {e}")


def main() -> None:
    target = input("Enter a website URL: ")
    check_status(target)


if __name__ == "__main__":
    main()

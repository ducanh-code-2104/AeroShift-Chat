
import getpass
import json
import urllib.request
import urllib.error

email = input("Email: ")
password = getpass.getpass("Password: ")

data = json.dumps({
    "email": email,
    "password": password
}).encode("utf-8")

request = urllib.request.Request(
    "http://127.0.0.1:3000/login",
    data=data,
    headers={"Content-Type": "application/json"},
    method="POST"
)

try:
    with urllib.request.urlopen(request) as response:
        result = json.load(response)

    token = result.get("token")

    if token:
        with open("/tmp/aeroshift_token.txt", "w") as f:
            f.write(token)

        print("Login successful!")
        print("User ID:", result["user"]["user_id"])
        print("JWT saved: True")
    else:
        print(result.get("message", "Login failed"))

except urllib.error.HTTPError as error:
    print("Login failed:", error.code)


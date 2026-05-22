import json
import urllib.request
import urllib.error
import datetime

api_key = 'AIzaSyD-OEsGxV6DoKGM-LWPAP7LCjkVVuxdK60'
project_id = 'abaarso-car-rental'
email = 'khadra@gmail.com'
password = 'password123'

def post_request(url, data, headers=None):
    if headers is None:
        headers = {}
    headers['Content-Type'] = 'application/json'
    req = urllib.request.Request(url, data=json.dumps(data).encode('utf-8'), headers=headers, method='POST')
    try:
        with urllib.request.urlopen(req) as response:
            return json.loads(response.read().decode('utf-8'))
    except urllib.error.HTTPError as e:
        print(f"Error calling {url}: {e.code} - {e.read().decode('utf-8')}")
        raise

def patch_request(url, data, headers=None):
    if headers is None:
        headers = {}
    headers['Content-Type'] = 'application/json'
    req = urllib.request.Request(url, data=json.dumps(data).encode('utf-8'), headers=headers, method='PATCH')
    try:
        with urllib.request.urlopen(req) as response:
            return json.loads(response.read().decode('utf-8'))
    except urllib.error.HTTPError as e:
        print(f"Error calling {url}: {e.code} - {e.read().decode('utf-8')}")
        raise

def main():
    # 1. Try to sign in or sign up
    try:
        print("Attempting to sign in...")
        auth_url = f"https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key={api_key}"
        auth_data = {"email": email, "password": password, "returnSecureToken": True}
        auth_res = post_request(auth_url, auth_data)
    except Exception:
        print("Sign in failed, attempting to sign up...")
        auth_url = f"https://identitytoolkit.googleapis.com/v1/accounts:signUp?key={api_key}"
        auth_data = {"email": email, "password": password, "returnSecureToken": True}
        auth_res = post_request(auth_url, auth_data)

    id_token = auth_res['idToken']
    uid = auth_res['localId']
    print(f"Authenticated successfully! UID: {uid}")

    headers = {'Authorization': f'Bearer {id_token}'}

    # 2. Write User Document to Firestore
    print("Writing user profile...")
    user_url = f"https://firestore.googleapis.com/v1/projects/{project_id}/databases/(default)/documents/users/{uid}"
    now_str = datetime.datetime.utcnow().isoformat() + 'Z'
    user_doc = {
        "fields": {
            "uid": {"stringValue": uid},
            "fullName": {"stringValue": "Khadra Ali"},
            "phone": {"stringValue": "+252635555555"},
            "role": {"stringValue": "customer"},
            "profileImageUrl": {"stringValue": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80"},
            "isVerified": {"booleanValue": False},
            "createdAt": {"timestampValue": now_str},
            "updatedAt": {"timestampValue": now_str}
        }
    }
    patch_request(user_url, user_doc, headers)
    print("User profile written successfully!")

    # 3. Write Booking Document to Firestore
    print("Writing booking record...")
    booking_id = "book_1779451781731_test"
    booking_url = f"https://firestore.googleapis.com/v1/projects/{project_id}/databases/(default)/documents/bookings/{booking_id}"

    start_date = now_str
    end_date = (datetime.datetime.utcnow() + datetime.timedelta(days=3)).isoformat() + 'Z'

    booking_doc = {
        "fields": {
            "bookingId": {"stringValue": booking_id},
            "userId": {"stringValue": uid},
            "carId": {"stringValue": "car_1779451781731"},
            "carBrandModel": {"stringValue": "White Sedan"},
            "carPlateNumber": {"stringValue": "SL 1234 HR"},
            "carImageUrl": {"stringValue": "https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?auto=format&fit=crop&w=600&q=80"},
            "userName": {"stringValue": "Khadra Ali"},
            "userPhone": {"stringValue": "+252635555555"},
            "startDate": {"timestampValue": start_date},
            "endDate": {"timestampValue": end_date},
            "totalDays": {"integerValue": "3"},
            "totalPrice": {"doubleValue": 135.0},
            "currency": {"stringValue": "USD"},
            "status": {"stringValue": "confirmed"},
            "paymentMethod": {"stringValue": "evc_plus"},
            "paymentStatus": {"stringValue": "paid"},
            "paymentReference": {"stringValue": "EVC-998877-TXT"},
            "driverNotes": {"stringValue": "Dalab kireysi oo loogu talagalay gaariga cusub."},
            "pickupLocationName": {"stringValue": "Jigjiga Yar, Hargeisa"},
            "pickupLocation": {"geoPointValue": {"latitude": 9.5750, "longitude": 44.0680}},
            "dropoffLocationName": {"stringValue": "Jigjiga Yar, Hargeisa"},
            "dropoffLocation": {"geoPointValue": {"latitude": 9.5750, "longitude": 44.0680}},
            "createdAt": {"timestampValue": now_str}
        }
    }
    patch_request(booking_url, booking_doc, headers)
    print("Booking created successfully in live Firestore!")

if __name__ == "__main__":
    main()

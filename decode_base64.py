# Simple python script for decoding a Base64 encoded string or password
import base64
import sys

def decode_base64_to_hex(b64_string):
    # Decode the Base64 encoded string
    try:
        decoded_bytes = base64.b64decode(b64_string)
    except Exception as e:
        sys.exit(f"Error decoding Base64: {e}")

    # Convert bytes to hex representation
    hex_string = decoded_bytes.hex()
    return hex_string

if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("Usage: python decode_base64_to_hex.py [Base64_String]")

    encoded_hash = sys.argv[1]
    hex_hash = decode_base64_to_hex(encoded_hash)
    print(f"Hexadecimal representation: {hex_hash}")

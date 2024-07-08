import requests

def stream_chat(prompt):
    url = 'http://127.0.0.1:1677/generate'  # Flask sunucunuzun URL'si
    headers = {'Content-Type': 'application/json'}
    data = {'prompt': prompt}

    response = requests.post(url, json=data, headers=headers, stream=True)

    if response.status_code == 200:
        for chunk in response.iter_content(chunk_size=None):
            if chunk:
                print(chunk.decode('utf-8'),end='', flush=True)  # Her bir yanıt parçasını doğrudan yazdırın
    else:
        print(f'Error: {response.status_code}')

if __name__ == "__main__":
    while True:
        prompt = input("Enter your prompt: ")
        stream_chat(prompt)
        print()  # Yanıt arasına boş bir satır ekleyin

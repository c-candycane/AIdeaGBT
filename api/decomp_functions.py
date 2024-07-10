import requests
import base64
from PIL import Image
from io import BytesIO
import pymupdf


def format_chat_history(chat_history):
    chatHistory = read_image(chat_history)
    read_pdf2(chatHistory)
    return chatHistory


def read_pdf2(chat_history):
    for message in chat_history:
        if 'files' in message:
            file_url = message['files']
            response = requests.get(file_url)
            response.raise_for_status()
            file_content, images = read_pdf(BytesIO(response.content))
            print(file_content)
            message['content'] ="There is a document, so answer the question about this:" +file_content + "\n" + message['content']
            if len(images) > 0:
                message['images'] = images

            print(chat_history)

            for i, img in enumerate(images):
                with open(f"extracted_image_{i}.jpeg", "wb") as f:
                    f.write(base64.b64decode(img))



def read_pdf(file_stream):
    content = ""
    images = []
    try:
        doc = pymupdf.open(stream=file_stream, filetype="pdf")
        for page in doc:
            content += page.get_text()
            for img_index, img in enumerate(doc.get_page_images(page.number)):
                xref = img[0]
                base_image = doc.extract_image(xref)
                image_bytes = base_image["image"]
                image = Image.open(BytesIO(image_bytes))
                buffered = BytesIO()
                image.save(buffered, format="JPEG")
                image_base64 = base64.b64encode(buffered.getvalue()).decode("utf-8")
                images.append(image_base64)
        return content, images
    except FileNotFoundError:
        return "Dosya bulunamadı.", []
    except Exception as e:
        return f"Bir hata oluştu: {e}", []


def download_image(image_url):
    response = requests.get(image_url)
    response.raise_for_status()
    return response.content


def read_image(chat_history):
    images_list = []
    for message in chat_history:
        if 'images' in message:
            image_url = message['images']
            try:
                image_bytes = download_image(image_url)
                image = Image.open(BytesIO(image_bytes))
                buffered = BytesIO()
                image.save(buffered, format="JPEG")
                image_base64 = base64.b64encode(buffered.getvalue()).decode("utf-8")
                images_list.append(image_base64)
            except requests.RequestException as e:
                print(f"Failed to download image: {e}")
                message['images'] = None
        message['images'] = images_list
    return chat_history

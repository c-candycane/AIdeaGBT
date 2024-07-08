from flask import Flask, request, Response, stream_with_context
from flask_cors import CORS
import decomp_functions as decomposition
from gbt_functions import generate_by_chat

app = Flask(__name__)
CORS(app)


@app.route('/chat', methods=['POST'])
def chat():
    data = request.json
    user_uid = data.get('userUid')
    chat_history = data.get('chatHistory')

    print(f'Received userUid: {user_uid}')
    print(f'Received chatHistory: {chat_history}')

    return Response(
        stream_with_context(
            generate_by_chat(
                model='qwen2', chat_history=chat_history)), content_type='text/plain')


@app.route('/generate_chat_title', methods=['POST'])
def generate_chat_title():
    data = request.json
    prompt = data.get('prompt')
    return prompt


@app.route('/chat_vision', methods=['POST'])
def chat_vision():
    data = request.json
    user_uid = data.get('userUid')
    chat_history = data.get('chatHistory')

    print(f'Received userUid: {user_uid}')
    print(f'Received chatHistory: {chat_history}')

    chat_history = decomposition.read_image(chat_history)

    return Response(
        stream_with_context(
            generate_by_chat(
                 model='chatgph/gph-main', chat_history=chat_history)), content_type='text/plain')


@app.route('/try')
def nh():
    return "hello"


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=1677)

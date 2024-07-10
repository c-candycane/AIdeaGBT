from flask import Flask, request, Response, stream_with_context
from flask_cors import CORS
from decomp_functions import format_chat_history
from gbt_functions import generate_by_chat, generate_by_prompt

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


@app.route('/chat_vision', methods=['POST'])
def chat_vision():
    data = request.json
    user_uid = data.get('userUid')
    chat_history = data.get('chatHistory')

    print(f'Received userUid: {user_uid}')
    print(f'Received chatHistory: {chat_history}')

    chat_history = format_chat_history(chat_history)

    return Response(
        stream_with_context(
            generate_by_chat(
                model='llava', chat_history=chat_history)), content_type='text/plain')


@app.route('/generate', methods=['POST'])
def generate():
    data = request.json
    user_uid = data.get('userUid')
    prompt = data.get('prompt')

    print(f'Received userUid: {user_uid}')
    print(f'Received prompt: {prompt}')

    return Response(
        stream_with_context(
            generate_by_prompt(
                model='qwen2', prompt=prompt)), content_type='text/plain')


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=1677)

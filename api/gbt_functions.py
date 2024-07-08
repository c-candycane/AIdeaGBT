import ollama


def generate_by_chat(model, chat_history):
    response_text = ""
    for part in ollama.chat(model=model, messages=chat_history, stream=True):
        if 'message' in part and 'content' in part['message']:
            response_text += part['message']['content'] + '\n'
            print(part['message']['content'])
            yield part['message']['content']
    yield '/end/'


def generate_by_prompt(model, prompt):
    for part in ollama.generate(model=model, options={'temperature': 0.1} ,prompt=prompt, stream=True):
        if 'response' in part:
            yield part['response']
    print(part)
    yield '/end/'
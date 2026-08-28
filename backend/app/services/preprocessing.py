import re


def clean_text(text: str) -> str:
    """Preserve the exact preprocessing behaviour of the current Streamlit app."""
    text = str(text)
    text = text.lower()
    text = re.sub(r"http\S+", "", text)
    text = re.sub(r"[^a-zA-Z0-9\s]", "", text)
    return text

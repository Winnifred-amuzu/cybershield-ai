# ============================================================
# AI PHISHING & SCAM DETECTION PLATFORM
# Streamlit + Machine Learning + NLP
# ============================================================


# =========================
# IMPORT LIBRARIES
# =========================

import streamlit as st

import pandas as pd

import joblib

import re

import sqlite3

from datetime import datetime

import plotly.express as px
import json
from pathlib import Path





# =========================
# PAGE CONFIG
# =========================


st.set_page_config(

    page_title="Cyber-Shield AI",

    layout="wide"

)





# =========================
# LOAD MODEL
# =========================

MODEL_DIR = Path("saved_models")
LEGACY_MODEL_PATH = MODEL_DIR / "best_model.pkl"
VECTORIZER_PATH = MODEL_DIR / "vectorizer.pkl"
CALIBRATED_MODEL_PATH = MODEL_DIR / "calibrated_svm.pkl"
CALIBRATION_METADATA_PATH = MODEL_DIR / "calibration_metadata.json"


@st.cache_resource
def load_model():
    vectorizer = joblib.load(VECTORIZER_PATH)

    if CALIBRATED_MODEL_PATH.exists():
        model = joblib.load(CALIBRATED_MODEL_PATH)
        metadata = {}
        if CALIBRATION_METADATA_PATH.exists():
            try:
                metadata = json.loads(CALIBRATION_METADATA_PATH.read_text(encoding="utf-8"))
            except (OSError, json.JSONDecodeError):
                metadata = {}
        return model, vectorizer, True, metadata

    model = joblib.load(LEGACY_MODEL_PATH)
    return model, vectorizer, False, {}


model, vectorizer, calibrated_model_active, calibration_metadata = load_model()


# =========================
# DATABASE
# =========================


def create_database():


    conn = sqlite3.connect(

        "history.db"

    )


    cursor = conn.cursor()



    cursor.execute(

        """

        CREATE TABLE IF NOT EXISTS history(

            id INTEGER PRIMARY KEY AUTOINCREMENT,

            message TEXT,

            source TEXT,

            prediction TEXT,

            confidence REAL,

            timestamp TEXT

        )

        """

    )


    conn.commit()

    conn.close()





create_database()





def save_history(

    message,

    source,

    prediction,

    confidence

):


    conn = sqlite3.connect(

        "history.db"

    )


    cursor = conn.cursor()



    cursor.execute(

        """

        INSERT INTO history

        VALUES(NULL,?,?,?,?,?)

        """,

        (

            message,

            source,

            prediction,

            confidence,

            datetime.now().strftime(

                "%Y-%m-%d %H:%M:%S"

            )

        )

    )


    conn.commit()

    conn.close()





def get_history():


    conn = sqlite3.connect(

        "history.db"

    )


    df = pd.read_sql(

        "SELECT * FROM history",

        conn

    )


    conn.close()


    return df







# =========================
# TEXT CLEANING
# =========================


def clean_text(text):


    text = str(text)


    text = text.lower()


    text = re.sub(

        r"http\S+",

        "",

        text

    )


    text = re.sub(

        r"[^a-zA-Z0-9\s]",

        "",

        text

    )


    return text






# =========================
# URL ANALYSIS
# =========================


def analyze_urls(message):


    results=[]


    urls = re.findall(

        r'https?://\S+',

        message

    )


    if urls:


        results.append(

            f"Found {len(urls)} URL(s)"

        )


        for url in urls:


            if len(url)>40:


                results.append(

                    "Long suspicious URL detected"

                )


            if "bit.ly" in url or "tinyurl" in url:


                results.append(

                    "URL shortener detected"

                )


    return results







# =========================
# EXPLAINABLE AI
# =========================


def explain_message(message):


    reasons=[]


    categories={


    "Urgency":

    [

    "urgent",

    "immediately",

    "now",

    "act"

    ],


    "Financial":

    [

    "money",

    "bank",

    "payment",

    "cash"

    ],


    "Account manipulation":

    [

    "verify",

    "password",

    "login",

    "account"

    ],


    "Reward scam":

    [

    "winner",

    "free",

    "claim",

    "prize"

    ]


    }



    lower=message.lower()



    for category,words in categories.items():


        for word in words:


            if word in lower:


                reasons.append(

                    f"{category} indicator detected: {word}"

                )



    reasons.extend(

        analyze_urls(message)

    )


    return reasons







# =========================
# RISK ENGINE
# =========================


def risk_level(scam_probability):

    if scam_probability < 0.30:
        return "LOW"
    elif scam_probability < 0.50:
        return "MEDIUM"
    elif scam_probability < 0.80:
        return "HIGH"
    else:
        return "CRITICAL"


# =========================
# SIDEBAR
# =========================


page = st.sidebar.selectbox(

    "Navigation",

    [

        "Detection",

        "Dashboard",

        "Model Performance",

        "History"

    ]

)





st.sidebar.title(

    "Cyber-Shield AI"

)


st.sidebar.write(

    "AI-powered phishing and scam detection"

)






# ============================================================
# DETECTION PAGE
# ============================================================


if page=="Detection":


    st.title(

        "AI Phishing & Scam Detector"

    )


    source = st.selectbox(

        "Message Source",

        [

            "Email",

            "SMS",

            "WhatsApp"

        ]

    )



    message = st.text_area(

        "Paste message",

        height=220

    )




    if st.button("Analyze Message"):



        if message.strip()=="":


            st.warning(

                "Enter a message"

            )


        else:


            cleaned = clean_text(message)


            vector = vectorizer.transform(

                [cleaned]

            )


            if calibrated_model_active:
                probabilities = model.predict_proba(vector)[0]
                scam_probability = float(probabilities[1])
                threshold = float(calibration_metadata.get("tuned_threshold", 0.50))
                prediction = int(scam_probability >= threshold)
                confidence = scam_probability if prediction == 1 else 1.0 - scam_probability
            else:
                prediction = int(model.predict(vector)[0])
                scam_probability = 0.80 if prediction == 1 else 0.20
                confidence = 0.80
                threshold = 0.50





            if prediction==1:


                result="SCAM / PHISHING"



            else:


                result="SAFE"





            st.divider()



            col1,col2,col3=st.columns(3)



            col1.metric(

                "Prediction",

                result

            )


            col2.metric(

                "Confidence",

                f"{confidence*100:.2f}%"

            )


            col3.metric(

                "Risk",

                risk_level(scam_probability)

            )


            if calibrated_model_active:
                st.caption(
                    f"Calibrated SVM active • Scam probability: {scam_probability * 100:.2f}% • "
                    f"Decision threshold: {threshold * 100:.2f}%"
                )
            else:
                st.warning(
                    "Calibrated SVM is not active. The displayed 80% confidence is a legacy fallback, not a calibrated probability. "
                    "Run ml/train_calibrated_model.py to enable calibrated confidence."
                )





            if prediction==1:


                st.error(

                    "Dangerous message detected"

                )


            else:


                st.success(

                    "Message appears safe"

                )





            st.subheader(

                "Why?"

            )


            explanations=explain_message(message)



            if explanations:


                for item in explanations:


                    st.write(

                        item

                    )


            else:


                st.write(

                    "No suspicious patterns detected"

                )





            save_history(

                message,

                source,

                result,

                confidence

            )








# ============================================================
# DASHBOARD
# ============================================================


elif page=="Dashboard":



    st.title(

        "Security Dashboard"

    )


    df=get_history()



    if len(df)==0:


        st.info(

            "No scans yet"

        )


    else:



        col1,col2=st.columns(2)



        col1.metric(

            "Total Scans",

            len(df)

        )


        col2.metric(

            "Threats Found",

            len(

            df[df.prediction!="SAFE"]

            )

        )





        fig=px.pie(

            df,

            names="prediction",

            title="Detection Distribution"

        )


        st.plotly_chart(fig)






# ============================================================
# MODEL PAGE
# ============================================================


elif page=="Model Performance":


    st.title(

        "Model Comparison"

    )


    results=pd.read_csv(

        "saved_models/model_comparison.csv"

    )


    st.dataframe(

        results,

        use_container_width=True

    )





    fig=px.bar(

        results,

        x="Model",

        y="F1",

        title="Model F1 Comparison"

    )


    st.plotly_chart(fig)






# ============================================================
# HISTORY PAGE
# ============================================================


elif page=="History":



    st.title(

        "Scan History"

    )



    df=get_history()



    st.dataframe(

        df,

        use_container_width=True

    )






# =========================
# FOOTER
# =========================


st.divider()


st.caption(

"Cyber-Shield AI | Machine Learning Cybersecurity Platform"

)
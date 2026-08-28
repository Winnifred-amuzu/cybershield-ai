# Cyber-Shield AI

# 1. Project Overview

Cyber-Shield AI is a machine learning-based cybersecurity application designed to detect phishing and scam messages from different digital communication platforms including:

* Email
* SMS
* WhatsApp messages

The system uses Natural Language Processing (NLP) techniques and machine learning classification algorithms to analyze message content and predict whether a message is:

* SAFE
* SCAM / PHISHING

The application also provides:

* Confidence score
* Risk level
* Suspicious pattern explanation
* URL analysis
* Detection history
* Model performance dashboard

The project was developed using:

* Python
* Scikit-learn
* Pandas
* NLP techniques
* Streamlit
* SQLite Database

---

# 2. System Architecture

The complete system follows this workflow:

```
          DATA SOURCES

          SMS Dataset
          Email Dataset
          WhatsApp Dataset

                  |

                  ↓


          DATA PREPROCESSING

          Cleaning Text
          Removing Noise
          Normalization

                  |

                  ↓


          FEATURE ENGINEERING

          TF-IDF Vectorization


                  |

                  ↓


          MACHINE LEARNING MODEL

          Naive Bayes
          Logistic Regression
          SVM
        


                  |

                  ↓


          SAVED MODEL FILES
        All trained models
          best_model.pkl
          vectorizer.pkl


                  |

                  ↓


          STREAMLIT APPLICATION


          User Input Message

                  |

                  ↓

          Text Processing

                  |

                  ↓

          Model Prediction

                  |

                  ↓

          Result Display


```

---

# 3. Project Folder Structure

The final project should look like:

```
Cyber-Shield-AI/


│
├── app.py
│
├── requirements.txt
│
├── saved_models/
│
│     ├── best_model.pkl
│     ├── vectorizer.pkl
│     └── model_comparison.csv
│
│
├── datasets/
│
│     ├── combined_label_dataset.csv
│     ├── smishing_dataset.csv
│     └── sms_phishing.csv
│
│
└── history.db


```

Explanation:

## app.py

The main Streamlit application.

It contains:

* User interface
* Model loading
* Prediction logic
* Dashboard
* Database functions

---

## saved_models/

Contains trained machine learning files.

### All saved models

This are all the models trained and saved.
It includes the btes model but it is resaved best_model.pkl


### best_model.pkl

The final selected machine learning model.

Example:

```
Logistic Regression
```

This is the model used for real predictions.

---

### vectorizer.pkl

Stores the TF-IDF text transformation object.

The model cannot understand raw text.

Example:

Input:

```
"Your account has been suspended"
```

The vectorizer converts it into numbers:

```
[0.23,0.45,0.12...]

```

The model uses these numbers for prediction.

---

# 4. Dataset Collection

The project uses multiple datasets because phishing occurs across different platforms.

Example datasets:

## SMS Dataset

Contains:

```
LABEL
TEXT
URL
EMAIL
PHONE

```

Example:

```
Smishing

Bank alert.
Click here to verify account.
```

---

## Smishing Dataset

Contains:

```
date
sender
network
text
language
scam_type

```

Example:

```
Your package is delayed.
Click this link.
```

---

## Combined Label Dataset

Contains:

```
message
spam label
smishing label

```

Example:

```
Your subscription will expire

spam = 1

```

---

# 5. Data Preparation Process

Because the datasets have different columns, they cannot be directly combined.

The important step is creating a common format.

All datasets are converted into:

```
message

label

```

Example:

Before:

Dataset 1:

```
TEXT

Hello friend

LABEL

ham

```

After:

```
message                 label

Hello friend             0

```

Dataset 2:

```
message

Click here now

spam label

1

```

Converted:

```
message                 label

Click here now           1

```

Now all datasets can be merged.

---

# 6. Text Preprocessing

Machine learning models cannot understand sentences directly.

The application performs cleaning:

## Lowercase conversion

Before:

```
BANK ACCOUNT ALERT

```

After:

```
bank account alert

```

---

## Removing URLs

Before:

```
Click https://abc.com

```

After:

```
Click

```

---

## Removing special characters

Before:

```
Win!!! $$$ Prize

```

After:

```
Win Prize

```

---

# 7. Feature Extraction

The project uses TF-IDF.

TF-IDF converts words into numerical values.

Example:

Message:

```
Verify your account immediately

```

Converted into:

```
[0.12,0.56,0.89]

```

The machine learning model uses these values.

---

# 8. Model Training Process

Several models are trained:

Example:

```
Naive Bayes

Logistic Regression

Support Vector Machine

```

Each model is evaluated using:

* Accuracy
* Precision
* Recall
* F1 Score
* Confusion Matrix

The best performing model is saved.

Example:

```
best_model.pkl

```

---

# 9. How Streamlit Loads the Model

When the application starts:

```python

model = joblib.load(
"saved_models/best_model.pkl"
)


vectorizer = joblib.load(
"saved_models/vectorizer.pkl"
)

```

The saved model is loaded into memory.

The model does not train again.

It only performs prediction.

---

# 10. Prediction Workflow

When a user enters:

```
Your bank account is suspended.
Click here immediately.
```

The application:

## Step 1

Cleans text:

```
your bank account is suspended click here immediately

```

## Step 2

Converts text using TF-IDF:

```
[0.34,0.76,0.55]

```

## Step 3

Model prediction:

```
1

```

## Step 4

Convert output:

```
1 = Scam

0 = Safe

```

## Step 5

Display:

```
Prediction:

SCAM / PHISHING


Confidence:

94%


Risk:

HIGH

```

---

# 11. Explainable AI Component

The system also checks suspicious patterns.

Examples:

## Urgency

Words:

```
urgent

immediately

now

```

---

## Financial

Words:

```
bank

money

payment

```

---

## Account manipulation

Words:

```
verify

password

login

```

---

## Reward scams

Words:

```
winner

free

claim

```

The system explains why a message was flagged.

---

# 12. URL Analysis

The system checks:

* Presence of links
* Long URLs
* URL shorteners

Example:

Input:

```
http://bit.ly/example

```

Output:

```
URL shortener detected

```

---

# 13. Database System

Cyber-Shield AI uses SQLite.

The database stores:

```
id

message

source

prediction

confidence

timestamp

```

Every prediction is saved.

This allows:

* History page
* Analytics dashboard
* Future user accounts

---

# 14. Streamlit Pages

The application contains four sections.

---

# Detection Page

Purpose:

Analyze new messages.

Features:

* Select platform
* Enter message
* Predict result
* Show confidence
* Explain detection

---

# Dashboard Page

Displays:

* Total scans
* Threat count
* Scam distribution chart

---

# Model Performance Page

Shows:

* Model comparison
* F1 scores
* Evaluation results

---

# History Page

Shows previous scans.

---

# 15. Running Locally

Install Python:

Recommended:

```
Python 3.10+

```

Create environment:

```
python -m venv venv

```

Activate:

Windows:

```
venv\Scripts\activate

```

Linux/Mac:

```
source venv/bin/activate

```

Install requirements:

```
pip install -r requirements.txt

```

Run application:

```
streamlit run app.py

```

The browser opens:

```
http://localhost:8501

```

---

# 16. requirements.txt

Example:

```
streamlit

pandas

scikit-learn

joblib

plotly

```

---

# 17. Deploying on Streamlit Cloud

## Step 1

Create GitHub repository

Upload:

```
app.py

requirements.txt

saved_models/

```

---

## Step 2

Open:

Streamlit Cloud

---

## Step 3

Connect GitHub account.

Select:

```
app.py

```

---

## Step 4

Click:

```
Deploy

```

Streamlit installs dependencies automatically.

The application becomes available online.

---

# 18. Important Deployment Notes

The saved model files must be uploaded.

Required:

```
saved_models/best_model.pkl

saved_models/vectorizer.pkl

```

Without these files the application cannot predict.

---

# 19. Future Improvements

Possible upgrades:

## Mobile Application

Android/iOS app

---

## WhatsApp API Integration

Automatic message scanning

---

## Email Integration

Scan incoming emails

---

## Deep Learning Models

Use:

* BERT
* Transformers

---

## Cloud Database

Replace SQLite with:

* PostgreSQL
* Firebase
* Supabase

---

# 20. Conclusion

Cyber-Shield AI demonstrates how machine learning and natural language processing can be applied to cybersecurity problems.

The system combines:

* Multiple cybersecurity datasets
* Text preprocessing
* Machine learning classification
* Explainable detection
* Risk assessment
* Data visualization

The project provides a foundation for developing a larger AI-powered cybersecurity assistant.

---

Author:

Cyber-Shield AI Development Team

Technology Stack:

Python | Machine Learning | NLP | Streamlit | SQLite

## Sprint 5 — ML Hardening

The project now includes an optional calibrated Linear SVM pipeline. Run `python ml/train_calibrated_model.py` after installing `backend/requirements.txt` to generate `saved_models/calibrated_svm.pkl` and calibration metadata. Until then, the existing model remains the compatibility fallback and the API explicitly labels its confidence as uncalibrated.

## Sprint 6 — Security Hardening

The backend now includes configurable CORS, request-size and input-length limits, API/authentication rate limiting, security headers and a production JWT-secret guard. See `SECURITY_SPRINT6.md` and `backend/.env.example`.


## Sprint 7 — Deployment & Release
See `DEPLOYMENT_SPRINT7.md` for PostgreSQL, Docker, HTTPS, migration and Android release instructions.


import os
import uuid
from datetime import datetime

import pandas as pd
import plotly.express as px
import requests
import streamlit as st


# ============================================================
# PAGE CONFIG
# ============================================================
st.set_page_config(
    page_title="AI Healthcare Analytics",
    page_icon="🏥",
    layout="wide",
    initial_sidebar_state="collapsed",
)


# ============================================================
# VISUAL DESIGN
# ============================================================
BACKGROUND_URL = (
    "https://images.unsplash.com/photo-1576091160399-112ba8d25d1d"
    "?auto=format&fit=crop&w=2200&q=85"
)

st.markdown(
    f"""
    <style>
        .stApp {{
            background:
                linear-gradient(
                    90deg,
                    rgba(5, 6, 6, 0.98) 0%,
                    rgba(5, 6, 6, 0.93) 48%,
                    rgba(5, 6, 6, 0.80) 100%
                ),
                url("{BACKGROUND_URL}") center / cover fixed no-repeat;
        }}

        [data-testid="stHeader"] {{
            background: transparent;
        }}

        .block-container {{
            max-width: 1180px;
            padding-top: 2rem;
            padding-bottom: 4rem;
        }}

        .eyebrow {{
            color: #a5dec9;
            font-size: 0.72rem;
            font-weight: 700;
            letter-spacing: 0.18em;
            text-transform: uppercase;
            margin-bottom: 0.8rem;
        }}

        .title {{
            font-size: 3.15rem;
            line-height: 1.03;
            letter-spacing: -0.05em;
            font-weight: 760;
            margin: 0;
            color: #f3f5f4;
        }}

        .subtitle {{
            color: #b7bfc0;
            font-size: 1.02rem;
            line-height: 1.65;
            max-width: 820px;
            margin-top: 0.9rem;
            margin-bottom: 1.8rem;
        }}

        .section-label {{
            color: #a5dec9;
            font-size: 0.75rem;
            font-weight: 700;
            letter-spacing: 0.14em;
            text-transform: uppercase;
            margin: 1.7rem 0 0.75rem 0;
        }}

        .answer-box {{
            background: rgba(10, 12, 12, 0.88);
            border: 1px solid rgba(255,255,255,0.085);
            border-radius: 18px;
            padding: 1rem 1.15rem;
            box-shadow: 0 18px 45px rgba(0,0,0,0.20);
        }}

        .notice-box {{
            background: rgba(34, 29, 20, 0.88);
            border: 1px solid rgba(214, 169, 92, 0.28);
            border-radius: 18px;
            padding: 1rem 1.15rem;
            box-shadow: 0 18px 45px rgba(0,0,0,0.18);
        }}

        .notice-title {{
            color: #f0d9ac;
            font-size: 1.05rem;
            font-weight: 700;
            margin-bottom: 0.35rem;
        }}

        .notice-text {{
            color: #d9d1c1;
            font-size: 0.94rem;
            line-height: 1.55;
        }}

        .kpi-card {{
            background: rgba(12, 14, 14, 0.80);
            border: 1px solid rgba(255,255,255,0.075);
            border-radius: 16px;
            padding: 0.9rem 1rem;
            min-height: 90px;
        }}

        .kpi-label {{
            color: #8e9799;
            font-size: 0.72rem;
            letter-spacing: 0.08em;
            text-transform: uppercase;
        }}

        .kpi-value {{
            color: #eef2f1;
            font-size: 1.45rem;
            font-weight: 650;
            margin-top: 0.25rem;
        }}

        .foot {{
            margin-top: 3rem;
            padding-top: 1rem;
            border-top: 1px solid rgba(255,255,255,0.08);
            color: #7f8889;
            text-align: center;
            font-size: 0.76rem;
        }}

        [data-testid="stChatMessage"] {{
            background: rgba(12, 14, 15, 0.72);
            border: 1px solid rgba(255,255,255,0.07);
            border-radius: 17px;
            margin-bottom: 0.7rem;
        }}

        [data-testid="stChatInput"] {{
            background: rgba(9, 10, 10, 0.92);
            border: 1px solid rgba(165, 222, 201, 0.18);
            border-radius: 18px;
        }}

        section[data-testid="stSidebar"] {{
            background: rgba(7, 8, 8, 0.98);
            border-right: 1px solid rgba(255,255,255,0.07);
        }}

        .stButton > button {{
            background: rgba(255,255,255,0.025);
            color: #e9eceb;
            border: 1px solid rgba(255,255,255,0.075);
            border-radius: 12px;
        }}

        .stButton > button:hover {{
            background: rgba(165,222,201,0.07);
            border-color: rgba(165,222,201,0.22);
        }}

        [data-testid="stExpander"] {{
            border: 1px solid rgba(255,255,255,0.07);
            border-radius: 14px;
            background: rgba(9,10,10,0.68);
        }}
    </style>
    """,
    unsafe_allow_html=True,
)


# ============================================================
# SESSION STATE
# ============================================================
if "messages" not in st.session_state:
    st.session_state.messages = []

if "queued_question" not in st.session_state:
    st.session_state.queued_question = None

# Stable ID for the current Streamlit browser session.
# n8n Simple Memory uses this to associate follow-up questions
# with the same conversation.
if "session_id" not in st.session_state:
    st.session_state.session_id = str(uuid.uuid4())


# ============================================================
# RESPONSE HELPERS
# ============================================================
def normalize_response(payload):
    if isinstance(payload, list):
        if payload and isinstance(payload[0], dict):
            return payload[0]
        return {"answer": str(payload)}

    if isinstance(payload, dict):
        for key in ("data", "result", "response"):
            value = payload.get(key)

            if isinstance(value, dict):
                return value

            if (
                isinstance(value, list)
                and value
                and isinstance(value[0], dict)
            ):
                return value[0]

        return payload

    return {"answer": str(payload)}


def call_n8n(question, webhook_url, timeout=120):
    started = datetime.now()

    response = requests.post(
        webhook_url,
        json={
            "question": question,
            "session_id": st.session_state.session_id,
        },
        timeout=timeout,
    )

    response.raise_for_status()

    try:
        payload = response.json()
    except ValueError:
        payload = {"answer": response.text}

    result = normalize_response(payload)

    result["_elapsed_seconds"] = round(
        (datetime.now() - started).total_seconds(),
        2,
    )

    return result


def get_answer(result):
    return (
        result.get("answer")
        or result.get("output")
        or result.get("text")
        or result.get("message")
        or "No answer was returned by the backend."
    )


def get_sql(result):
    return (
        result.get("sql")
        or result.get("generated_sql")
        or result.get("query")
    )


# ============================================================
# FRIENDLY ERROR HANDLING
# ============================================================
def classify_backend_error(exc):
    """
    Convert technical backend/API errors into a polished user-facing
    message. Classification uses HTTP status first, then backend text.
    """
    response = getattr(exc, "response", None)
    status_code = getattr(response, "status_code", None)

    raw = ""
    if response is not None:
        try:
            raw = response.text.lower()
        except Exception:
            raw = ""

    raw += " " + str(exc).lower()

    # -----------------------------
    # Explicit Gemini / AI signals
    # -----------------------------
    ai_terms = (
        "gemini",
        "generativelanguage",
        "google generative ai",
        "generatecontent",
        "quota exceeded",
        "free_tier_requests",
        "free_tier_input_token_count",
        "model is currently experiencing",
        "high demand",
        "rate limit",
        "429 too many requests",
    )

    if any(term in raw for term in ai_terms):
        if status_code == 429 or "quota" in raw or "rate limit" in raw:
            return (
                "AI rate limit reached",
                "The AI service has reached its current request or usage limit. "
                "Please wait a little while and try again.",
            )

        return (
            "AI service temporarily unavailable",
            "The analytics assistant could not process your request because "
            "the AI service is temporarily unavailable. Please try again shortly.",
        )

    # -----------------------------
    # Generic HTTP status handling
    # -----------------------------
    if status_code == 429:
        return (
            "Too many requests",
            "The analytics service is temporarily rate-limited. "
            "Please wait a little while and try again.",
        )

    if status_code == 503:
        return (
            "Analytics service temporarily unavailable",
            "The analytics workflow is temporarily unavailable. "
            "Please try again in a moment.",
        )

    # -----------------------------
    # Snowflake / database signals
    # -----------------------------
    database_terms = (
        "snowflake",
        "sql compilation error",
        "warehouse",
        "database",
        "invalid identifier",
        "object does not exist",
        "statement",
        "authentication",
    )

    if any(term in raw for term in database_terms):
        return (
            "Data source error",
            "We couldn't retrieve the requested healthcare data from the "
            "analytics database. Please try again or rephrase the question.",
        )

    # -----------------------------
    # SQL / validation signals
    # -----------------------------
    sql_terms = (
        "sql syntax",
        "syntax error",
        "query",
        "validation",
        "read-only",
        "select only",
        "unsafe query",
    )

    if any(term in raw for term in sql_terms):
        return (
            "Unable to process this analysis",
            "The requested analysis could not be executed successfully. "
            "Try rephrasing the question or simplifying the comparison.",
        )

    # -----------------------------
    # Generic 4xx/5xx
    # -----------------------------
    if status_code is not None and 500 <= status_code < 600:
        return (
            "Analytics workflow error",
            "The analytics workflow encountered a temporary server-side "
            "problem. Please try again in a moment.",
        )

    if status_code is not None and 400 <= status_code < 500:
        return (
            "Request could not be completed",
            "The analytics service could not process this request. "
            "Please check the question and try again.",
        )

    return (
        "Something went wrong",
        "We couldn't complete this request right now. Please try again.",
    )


def show_friendly_notice(title, message, technical_details=None):
    st.markdown(
        f"""
        <div class="notice-box">
            <div class="notice-title">⚠ {title}</div>
            <div class="notice-text">{message}</div>
        </div>
        """,
        unsafe_allow_html=True,
    )

    if technical_details:
        with st.expander("Technical details"):
            st.code(str(technical_details))


# ============================================================
# TABLE / CHART HELPERS
# ============================================================
def parse_markdown_table(text):
    lines = [
        line.strip()
        for line in str(text).splitlines()
        if line.strip()
    ]

    for i in range(len(lines) - 2):
        if not lines[i].startswith("|"):
            continue
        if not lines[i + 1].startswith("|"):
            continue
        if "-" not in lines[i + 1]:
            continue

        raw_rows = [lines[i], lines[i + 1]]
        j = i + 2

        while j < len(lines) and lines[j].startswith("|"):
            raw_rows.append(lines[j])
            j += 1

        try:
            parsed = [
                [cell.strip() for cell in row.strip("|").split("|")]
                for row in raw_rows
            ]

            columns = parsed[0]
            data = parsed[2:]

            if not data:
                continue

            df = pd.DataFrame(data, columns=columns)

            for col in df.columns:
                cleaned = (
                    df[col]
                    .astype(str)
                    .str.replace("$", "", regex=False)
                    .str.replace(",", "", regex=False)
                    .str.replace("%", "", regex=False)
                    .str.strip()
                )

                numeric = pd.to_numeric(
                    cleaned,
                    errors="coerce",
                )

                if numeric.notna().mean() >= 0.7:
                    df[col] = numeric

            return df

        except Exception:
            continue

    return None


def should_chart(question, df):
    if df is None or df.empty:
        return False

    numeric = df.select_dtypes(include="number").columns.tolist()
    categorical = [c for c in df.columns if c not in numeric]

    if not numeric or not categorical:
        return False

    q = question.lower()

    keywords = (
        "top",
        "bottom",
        "highest",
        "lowest",
        "compare",
        "comparison",
        "ranking",
        "rank",
        "distribution",
        "trend",
        "over time",
        "by ",
    )

    return any(keyword in q for keyword in keywords)


def render_chart(question, df):
    numeric = df.select_dtypes(include="number").columns.tolist()
    categorical = [c for c in df.columns if c not in numeric]

    if not numeric or not categorical:
        return

    x = categorical[0]
    y = numeric[0]

    fig = px.bar(
        df,
        x=x,
        y=y,
        template="plotly_dark",
        title=question.rstrip("?"),
    )

    fig.update_layout(
        paper_bgcolor="rgba(0,0,0,0)",
        plot_bgcolor="rgba(0,0,0,0)",
        font=dict(color="#E8ECEB"),
        title_font_size=16,
        margin=dict(l=10, r=10, t=55, b=10),
        xaxis_title=None,
        yaxis_title=None,
        showlegend=False,
    )

    # Keep the chart styling consistent with the black/mint UI.
    fig.update_traces(
        marker_color="#9FE2CB",
        marker_line_width=0,
        hovertemplate="%{x}<br>%{y}<extra></extra>",
    )

    st.plotly_chart(
        fig,
        use_container_width=True,
        config={"displayModeBar": False},
    )


# ============================================================
# SIDEBAR
# ============================================================
with st.sidebar:
    st.markdown("## Healthcare AI")

    default_webhook = os.getenv(
        "N8N_WEBHOOK_URL",
        "http://localhost:5678/webhook/healthcare-ai",
    )

    webhook_url = st.text_input(
        "n8n Production Webhook URL",
        value=default_webhook,
    )

    st.divider()

    st.markdown("### Suggested questions")

    suggestions = [
        "How many providers are there?",
        "What is the total claim amount by specialty?",
        "Which payer has the highest covered encounters?",
        "Show the top 5 specialties by claim amount.",
        "Compare claim amount and payer coverage by specialty.",
    ]

    for suggestion in suggestions:
        if st.button(
            suggestion,
            use_container_width=True,
            key="q_" + suggestion,
        ):
            st.session_state.queued_question = suggestion
            st.rerun()

    st.divider()
    st.caption("Streamlit • n8n • Gemini • Snowflake")


# ============================================================
# HEADER
# ============================================================
st.markdown(
    """
    <div class="eyebrow">Agentic Healthcare Intelligence</div>
    <div class="title">Ask your healthcare data anything.</div>
    <div class="subtitle">
        A conversational analytics agent that turns natural-language business
        questions into governed SQL, queries Snowflake, and presents results
        as clear answers and visual insights.
    </div>
    """,
    unsafe_allow_html=True,
)


# ============================================================
# SYSTEM STRIP
# ============================================================
c1, c2, c3 = st.columns(3)

with c1:
    st.markdown(
        """
        <div class="kpi-card">
            <div class="kpi-label">Data source</div>
            <div class="kpi-value">Snowflake</div>
        </div>
        """,
        unsafe_allow_html=True,
    )

with c2:
    st.markdown(
        """
        <div class="kpi-card">
            <div class="kpi-label">Orchestration</div>
            <div class="kpi-value">n8n Agentic Workflow</div>
        </div>
        """,
        unsafe_allow_html=True,
    )

with c3:
    st.markdown(
        """
        <div class="kpi-card">
            <div class="kpi-label">AI model</div>
            <div class="kpi-value">Gemini Flash</div>
        </div>
        """,
        unsafe_allow_html=True,
    )


# ============================================================
# CHAT
# ============================================================
st.markdown(
    '<div class="section-label">Healthcare AI Analyst</div>',
    unsafe_allow_html=True,
)

# No custom avatars are used anywhere in this file.
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

        if message.get("chart_df") is not None:
            st.markdown(
                '<div class="section-label">Visual Insight</div>',
                unsafe_allow_html=True,
            )

            st.dataframe(
                message["chart_df"],
                use_container_width=True,
                hide_index=True,
            )

            if message.get("chart_question"):
                render_chart(
                    message["chart_question"],
                    message["chart_df"],
                )

        if message.get("sql"):
            with st.expander("View generated SQL"):
                st.code(
                    message["sql"],
                    language="sql",
                )


typed_question = st.chat_input(
    "Ask a healthcare analytics question..."
)

question = typed_question or st.session_state.queued_question

if question:
    st.session_state.queued_question = None

    st.session_state.messages.append(
        {
            "role": "user",
            "content": question,
        }
    )

    with st.chat_message("user"):
        st.markdown(question)

    with st.chat_message("assistant"):
        with st.spinner("Analyzing the healthcare data..."):
            try:
                result = call_n8n(
                    question,
                    webhook_url,
                )

                answer = get_answer(result)
                sql = get_sql(result)

                # --------------------------------------------
                # Answer
                # --------------------------------------------
                st.markdown(
                    '<div class="section-label">AI Answer</div>',
                    unsafe_allow_html=True,
                )

                st.markdown(answer)

                # --------------------------------------------
                # Optional chart
                # --------------------------------------------
                chart_df = parse_markdown_table(answer)
                use_chart = should_chart(
                    question,
                    chart_df,
                )

                if use_chart:
                    st.markdown(
                        '<div class="section-label">Visual Insight</div>',
                        unsafe_allow_html=True,
                    )

                    st.dataframe(
                        chart_df,
                        use_container_width=True,
                        hide_index=True,
                    )

                    render_chart(
                        question,
                        chart_df,
                    )

                # --------------------------------------------
                # Metadata
                # --------------------------------------------
                k1, k2, k3 = st.columns(3)

                # Do not label an unreported result SUCCESS.
                returned_status = (
                    result.get("status")
                    or result.get("validation_status")
                )

                display_status = (
                    str(returned_status).upper()
                    if returned_status
                    else "COMPLETED"
                )

                with k1:
                    st.metric(
                        "Status",
                        display_status,
                    )

                with k2:
                    st.metric(
                        "Response time",
                        f'{result.get("_elapsed_seconds", "—")} s',
                    )

                with k3:
                    st.metric(
                        "Data source",
                        "Snowflake",
                    )

                # --------------------------------------------
                # SQL
                # --------------------------------------------
                if sql:
                    with st.expander(
                        "View generated SQL",
                    ):
                        st.code(
                            str(sql),
                            language="sql",
                        )

                # --------------------------------------------
                # Save session message
                # --------------------------------------------
                st.session_state.messages.append(
                    {
                        "role": "assistant",
                        "content": answer,
                        "sql": sql,
                        "chart_df": chart_df if use_chart else None,
                        "chart_question": (
                            question if use_chart else None
                        ),
                    }
                )

            # --------------------------------------------
            # Friendly error states
            # --------------------------------------------
            except requests.exceptions.ConnectionError as exc:
                show_friendly_notice(
                    "Analytics service unavailable",
                    "The assistant could not connect to the analytics service. "
                    "Please make sure n8n is running and the production webhook is active.",
                    exc,
                )

            except requests.exceptions.Timeout as exc:
                show_friendly_notice(
                    "Request timed out",
                    "The analysis is taking longer than expected. "
                    "Please try again or simplify the question.",
                    exc,
                )

            except requests.exceptions.HTTPError as exc:
                title, message = classify_backend_error(exc)

                show_friendly_notice(
                    title,
                    message,
                    exc,
                )

            except Exception as exc:
                title, message = classify_backend_error(exc)

                show_friendly_notice(
                    title,
                    message,
                    exc,
                )


# ============================================================
# ABOUT
# ============================================================
with st.expander("About this assistant"):
    st.markdown(
        """
        ### Architecture

        ```text
        Streamlit
            ↓
        n8n Production Webhook
            ↓
        AI Agent + Gemini
            ↓
        Healthcare SQL Tool
            ↓
        SQL Validator
            ↓
        Snowflake CLEAN_SCHEMA
            ↓
        AI Response
        ```

        ### What it demonstrates

        - Conversational natural-language analytics
        - AI-generated SQL
        - Governed read-only database access
        - Snowflake-based healthcare analytics
        - Dynamic comparison charts
        - Backend audit logging

        ### Error handling

        Infrastructure and model errors are translated into user-friendly
        messages in the interface. Technical details remain available only
        inside the optional technical-details panel for debugging.
        """
    )


# ============================================================
# FOOTER
# ============================================================
st.markdown(
    '<div class="foot">AI Healthcare Analytics Assistant • Portfolio Prototype</div>',
    unsafe_allow_html=True,
)

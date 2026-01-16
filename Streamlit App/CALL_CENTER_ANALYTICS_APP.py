# Call Center Analytics Dashboard
# Advanced Call Center Intelligence with Snowflake Cortex AI
# Adapted for Snowflake World Tour 2025 London Demo

import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from snowflake.snowpark.context import get_active_session

# Initialize Snowflake session
session = get_active_session()

# Page configuration
st.set_page_config(
    page_title="Call Center Analytics Dashboard",
    page_icon="📞",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for enhanced styling
st.markdown("""
<style>
    .main-header {
        font-size: 2.5rem;
        font-weight: bold;
        color: #1E293B;
        text-align: center;
        margin-bottom: 2rem;
        background: linear-gradient(90deg, #29B5E8, #10B981);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
    }
    
    .metric-card {
        background: white;
        padding: 1rem;
        border-radius: 0.5rem;
        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        border-left: 4px solid #29B5E8;
    }
    
    .customer-card {
        background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
        padding: 1.5rem;
        border-radius: 1rem;
        margin: 1rem 0;
        border: 1px solid #e2e8f0;
    }
    
    .priority-high {
        background-color: #fee2e2;
        border-left: 4px solid #ef4444;
        padding: 1rem;
        border-radius: 0.5rem;
        margin: 0.5rem 0;
    }
    
    .priority-medium {
        background-color: #fef3c7;
        border-left: 4px solid #f59e0b;
        padding: 1rem;
        border-radius: 0.5rem;
        margin: 0.5rem 0;
    }
    
    .priority-low {
        background-color: #d1fae5;
        border-left: 4px solid #10b981;
        padding: 1rem;
        border-radius: 0.5rem;
        margin: 0.5rem 0;
    }
    
    .sentiment-positive { color: #10b981; font-weight: bold; }
    .sentiment-negative { color: #ef4444; font-weight: bold; }
    .sentiment-neutral { color: #6b7280; font-weight: bold; }
</style>
""", unsafe_allow_html=True)


# ============================================
# DATA LOADING FUNCTIONS
# ============================================

@st.cache_data(show_spinner=False)
def load_call_data():
    """Load call center data from the main table"""
    query = """
    SELECT *
    FROM CALL_CENTER_ANALYTICS.AUDIO_PROCESSING.AI_TRANSCRIBED_CALLS_AI_GENERATED
    ORDER BY ANALYSIS_TIMESTAMP DESC
    """
    return session.sql(query).to_pandas()


@st.cache_data(show_spinner=False)
def load_customer_profiles():
    """Load customer profile data"""
    query = """
    SELECT *
    FROM CALL_CENTER_ANALYTICS.AUDIO_PROCESSING.AI_TRANSCRIBED_CALLS_AI_GENERATED_CUSTOMER_PROFILE
    """
    return session.sql(query).to_pandas()


@st.cache_data(show_spinner=False)
def get_summary_stats():
    """Get summary statistics for the dashboard"""
    query = """
    SELECT 
        COUNT(*) as total_calls,
        COUNT(DISTINCT CUSTOMER_NAME) as unique_customers,
        COUNT(DISTINCT AGENT_NAME) as unique_agents,
        ROUND(AVG(SENTIMENT_SCORE), 3) as avg_sentiment_score,
        ROUND(AVG(AGENT_PERFORMANCE_SCORE), 1) as avg_agent_score,
        SUM(CASE WHEN ISSUE_RESOLVED = 'yes' THEN 1 ELSE 0 END) as resolved_calls,
        SUM(CASE WHEN ESCALATION_REQUIRED = 'yes' THEN 1 ELSE 0 END) as escalated_calls,
        SUM(CASE WHEN CUSTOMER_SATISFACTION = 'satisfied' THEN 1 ELSE 0 END) as satisfied_customers,
        SUM(CASE WHEN SENTIMENT_CATEGORY = 'NEGATIVE' THEN 1 ELSE 0 END) as negative_calls
    FROM CALL_CENTER_ANALYTICS.AUDIO_PROCESSING.AI_TRANSCRIBED_CALLS_AI_GENERATED
    """
    return session.sql(query).collect()[0]


def create_sentiment_gauge(sentiment_score):
    """Create a sentiment gauge chart"""
    fig = go.Figure(go.Indicator(
        mode="gauge+number",
        value=sentiment_score,
        domain={'x': [0, 1], 'y': [0, 1]},
        title={'text': "Avg Sentiment"},
        gauge={
            'axis': {'range': [-1, 1]},
            'bar': {'color': "darkblue"},
            'steps': [
                {'range': [-1, -0.3], 'color': "lightcoral"},
                {'range': [-0.3, 0.3], 'color': "lightyellow"},
                {'range': [0.3, 1], 'color': "lightgreen"}
            ]
        }
    ))
    fig.update_layout(height=250)
    return fig


# ============================================
# PAGE FUNCTIONS
# ============================================

def show_executive_dashboard(call_data, stats):
    """Executive Dashboard with key metrics and insights"""
    st.markdown("## 📊 Executive Dashboard")
    
    # Key Metrics Row
    col1, col2, col3, col4, col5 = st.columns(5)
    
    with col1:
        st.metric("📞 Total Calls", f"{stats['TOTAL_CALLS']:,}")
    
    with col2:
        st.metric("👥 Customers", f"{stats['UNIQUE_CUSTOMERS']:,}")
    
    with col3:
        resolution_rate = (stats['RESOLVED_CALLS'] / stats['TOTAL_CALLS'] * 100) if stats['TOTAL_CALLS'] > 0 else 0
        st.metric("✅ Resolution Rate", f"{resolution_rate:.1f}%")
    
    with col4:
        satisfaction_rate = (stats['SATISFIED_CUSTOMERS'] / stats['TOTAL_CALLS'] * 100) if stats['TOTAL_CALLS'] > 0 else 0
        st.metric("😊 Satisfaction Rate", f"{satisfaction_rate:.1f}%")
    
    with col5:
        st.metric("⭐ Avg Agent Score", f"{stats['AVG_AGENT_SCORE']:.1f}/10")
    
    # Charts Row
    col1, col2 = st.columns(2)
    
    with col1:
        # Sentiment Distribution
        sentiment_counts = call_data['SENTIMENT_CATEGORY'].value_counts()
        fig_sentiment = px.pie(
            values=sentiment_counts.values,
            names=sentiment_counts.index,
            title="📊 Call Sentiment Distribution",
            color_discrete_map={
                'POSITIVE': '#10B981',
                'NEUTRAL': '#29B5E8',
                'NEGATIVE': '#EF4444'
            }
        )
        fig_sentiment.update_layout(height=400)
        st.plotly_chart(fig_sentiment, use_container_width=True)
    
    with col2:
        # Call Intent Categories
        intent_counts = call_data['PRIMARY_INTENT'].value_counts().head(6)
        fig_intent = px.bar(
            x=intent_counts.values,
            y=intent_counts.index,
            orientation='h',
            title="🏷️ Call Intent Categories",
            color=intent_counts.values,
            color_continuous_scale="viridis"
        )
        fig_intent.update_layout(height=400, showlegend=False)
        st.plotly_chart(fig_intent, use_container_width=True)
    
    # Priority Issues Section
    st.markdown("## 🚨 Calls Requiring Attention")
    
    priority_calls = call_data[
        (call_data['ESCALATION_REQUIRED'] == 'yes') | 
        (call_data['SENTIMENT_CATEGORY'] == 'NEGATIVE')
    ].head(5)
    
    if not priority_calls.empty:
        for _, call in priority_calls.iterrows():
            priority_class = "priority-high" if call['ESCALATION_REQUIRED'] == 'yes' else "priority-medium"
            st.markdown(f"""
            <div class="{priority_class}">
                <strong>🚨 {call['CUSTOMER_NAME']} - {call['PRIMARY_INTENT']}</strong><br>
                <em>Agent: {call['AGENT_NAME']} | Sentiment: {call['SENTIMENT_CATEGORY']}</em><br>
                {str(call['CALL_SUMMARY'])[:200]}...
            </div>
            """, unsafe_allow_html=True)
    else:
        st.success("✅ No high-priority issues at this time!")


def show_agent_performance(call_data):
    """Agent performance analysis"""
    st.markdown("## 👨‍💼 Agent Performance Analysis")
    
    # Agent summary
    agent_stats = call_data.groupby('AGENT_NAME').agg({
        'CALL_ID': 'count',
        'SENTIMENT_SCORE': 'mean',
        'AGENT_PERFORMANCE_SCORE': 'mean',
        'ISSUE_RESOLVED': lambda x: (x == 'yes').sum(),
        'CUSTOMER_SATISFACTION': lambda x: (x == 'satisfied').sum()
    }).reset_index()
    
    agent_stats.columns = ['Agent', 'Total Calls', 'Avg Sentiment', 'Performance Score', 'Resolved', 'Satisfied']
    agent_stats['Resolution Rate'] = (agent_stats['Resolved'] / agent_stats['Total Calls'] * 100).round(1)
    agent_stats['Satisfaction Rate'] = (agent_stats['Satisfied'] / agent_stats['Total Calls'] * 100).round(1)
    agent_stats = agent_stats.sort_values('Performance Score', ascending=False)
    
    # Top Performers
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("### 🏆 Top Performing Agents")
        top_agents = agent_stats.head(5)[['Agent', 'Performance Score', 'Resolution Rate', 'Satisfaction Rate']]
        st.dataframe(top_agents, use_container_width=True, hide_index=True)
    
    with col2:
        # Performance distribution chart
        fig_perf = px.bar(
            agent_stats.head(10),
            x='Agent',
            y='Performance Score',
            title="Agent Performance Scores",
            color='Performance Score',
            color_continuous_scale='RdYlGn'
        )
        fig_perf.update_layout(height=400)
        st.plotly_chart(fig_perf, use_container_width=True)
    
    # Detailed agent table
    st.markdown("### 📋 Full Agent Summary")
    st.dataframe(agent_stats, use_container_width=True, hide_index=True)


def show_customer_insights(call_data, customer_data):
    """Customer insights and profiles"""
    st.markdown("## 👤 Customer Insights")
    
    # Customer selector
    customers = call_data['CUSTOMER_NAME'].dropna().unique()
    selected_customer = st.selectbox("Select Customer", sorted(customers))
    
    if selected_customer:
        customer_calls = call_data[call_data['CUSTOMER_NAME'] == selected_customer]
        
        # Customer profile if available
        customer_profile = customer_data[customer_data['CUSTOMER_NAME'] == selected_customer]
        
        col1, col2, col3 = st.columns([2, 1, 1])
        
        with col1:
            st.markdown(f"""
            <div class="customer-card">
                <h2>👤 {selected_customer}</h2>
                <p><strong>Total Calls:</strong> {len(customer_calls)}</p>
            </div>
            """, unsafe_allow_html=True)
            
            if not customer_profile.empty:
                profile = customer_profile.iloc[0]
                st.write(f"**Segment:** {profile.get('CUSTOMER_SEGMENT', 'N/A')}")
                st.write(f"**Region:** {profile.get('REGION', 'N/A')}")
                st.write(f"**Lifetime Value:** ${profile.get('LIFETIME_VALUE', 0):,.2f}")
        
        with col2:
            avg_sentiment = customer_calls['SENTIMENT_SCORE'].mean()
            st.plotly_chart(create_sentiment_gauge(avg_sentiment), use_container_width=True)
        
        with col3:
            resolved = (customer_calls['ISSUE_RESOLVED'] == 'yes').sum()
            st.metric("Issues Resolved", f"{resolved}/{len(customer_calls)}")
            satisfied = (customer_calls['CUSTOMER_SATISFACTION'] == 'satisfied').sum()
            st.metric("Satisfied Calls", satisfied)
        
        # Customer call history
        st.markdown("### 📞 Call History")
        for _, call in customer_calls.head(5).iterrows():
            with st.expander(f"{call['PRIMARY_INTENT']} - {call['ANALYSIS_TIMESTAMP']}"):
                st.write(f"**Agent:** {call['AGENT_NAME']}")
                st.write(f"**Sentiment:** {call['SENTIMENT_CATEGORY']} ({call['SENTIMENT_SCORE']:.2f})")
                st.write(f"**Resolved:** {call['ISSUE_RESOLVED']}")
                st.write(f"**Summary:** {call['CALL_SUMMARY']}")


def show_regional_analysis(call_data, customer_data):
    """Regional analysis with customer data"""
    st.markdown("## 🗺️ Regional Analysis")
    
    # Merge call data with customer profiles for region info
    merged_data = call_data.merge(
        customer_data[['CUSTOMER_NAME', 'REGION', 'CUSTOMER_SEGMENT', 'LIFETIME_VALUE']],
        on='CUSTOMER_NAME',
        how='left'
    )
    
    if 'REGION' in merged_data.columns and merged_data['REGION'].notna().any():
        # Regional metrics
        regional_stats = merged_data.groupby('REGION').agg({
            'CALL_ID': 'count',
            'SENTIMENT_SCORE': 'mean',
            'ISSUE_RESOLVED': lambda x: (x == 'yes').sum(),
            'CUSTOMER_SATISFACTION': lambda x: (x == 'satisfied').sum(),
            'LIFETIME_VALUE': 'sum'
        }).reset_index()
        
        regional_stats.columns = ['Region', 'Calls', 'Avg Sentiment', 'Resolved', 'Satisfied', 'Total LTV']
        regional_stats['Resolution Rate'] = (regional_stats['Resolved'] / regional_stats['Calls'] * 100).round(1)
        regional_stats['Satisfaction Rate'] = (regional_stats['Satisfied'] / regional_stats['Calls'] * 100).round(1)
        
        col1, col2 = st.columns(2)
        
        with col1:
            fig_region = px.bar(
                regional_stats,
                x='Region',
                y='Satisfaction Rate',
                title="Customer Satisfaction by Region",
                color='Satisfaction Rate',
                color_continuous_scale='RdYlGn'
            )
            st.plotly_chart(fig_region, use_container_width=True)
        
        with col2:
            fig_ltv = px.bar(
                regional_stats,
                x='Region',
                y='Total LTV',
                title="Total Customer Value by Region",
                color='Total LTV',
                color_continuous_scale='Blues'
            )
            st.plotly_chart(fig_ltv, use_container_width=True)
        
        st.dataframe(regional_stats, use_container_width=True, hide_index=True)
    else:
        st.info("Regional data not available. Ensure customer profiles are loaded.")


def show_transcript_search(call_data):
    """Search through call transcripts"""
    st.markdown("## 🔍 Transcript Search")
    
    search_term = st.text_input("Search transcripts:", placeholder="Enter keywords...")
    
    if search_term:
        # Filter transcripts containing the search term
        matches = call_data[
            call_data['TRANSCRIPT_TEXT'].str.contains(search_term, case=False, na=False)
        ]
        
        st.write(f"Found **{len(matches)}** matching calls")
        
        for _, call in matches.head(10).iterrows():
            sentiment_color = "sentiment-positive" if call['SENTIMENT_CATEGORY'] == 'POSITIVE' else \
                             "sentiment-negative" if call['SENTIMENT_CATEGORY'] == 'NEGATIVE' else "sentiment-neutral"
            
            with st.expander(f"📞 {call['CUSTOMER_NAME']} - {call['PRIMARY_INTENT']}"):
                col1, col2 = st.columns([3, 1])
                with col1:
                    st.write(f"**Summary:** {call['CALL_SUMMARY']}")
                    st.write(f"**Transcript excerpt:** ...{str(call['TRANSCRIPT_TEXT'])[:500]}...")
                with col2:
                    st.markdown(f"**Sentiment:** <span class='{sentiment_color}'>{call['SENTIMENT_CATEGORY']}</span>", 
                               unsafe_allow_html=True)
                    st.write(f"**Agent:** {call['AGENT_NAME']}")
                    st.write(f"**Resolved:** {call['ISSUE_RESOLVED']}")


# ============================================
# MAIN APP
# ============================================

def main():
    # Header
    st.markdown('<h1 class="main-header">📞 Call Center Analytics Dashboard</h1>', unsafe_allow_html=True)
    st.markdown("### Powered by Snowflake Cortex AI | SWT 2025 London Demo")
    
    # Load data
    try:
        call_data = load_call_data()
        customer_data = load_customer_profiles()
        stats = get_summary_stats()
    except Exception as e:
        st.error(f"Error loading data: {e}")
        st.info("Please ensure the demo tables are created by running the SQL setup scripts.")
        return
    
    # Sidebar navigation
    with st.sidebar:
        st.image("https://www.snowflake.com/wp-content/themes/flavor/flavor-assets/images/logos/snowflake-logo-color@2x.png", width=200)
        st.markdown("### 🎯 Navigation")
        
        page = st.selectbox(
            "Select View",
            ["📊 Executive Dashboard", "👨‍💼 Agent Performance", "👤 Customer Insights", 
             "🗺️ Regional Analysis", "🔍 Transcript Search"]
        )
        
        st.markdown("---")
        st.markdown("### 📈 Quick Stats")
        st.metric("Total Calls", stats['TOTAL_CALLS'])
        st.metric("Avg Sentiment", f"{stats['AVG_SENTIMENT_SCORE']:.2f}")
        
        st.markdown("---")
        st.markdown("### 🎛️ Filters")
        
        # Sentiment filter
        sentiment_filter = st.multiselect(
            "Sentiment",
            options=['POSITIVE', 'NEUTRAL', 'NEGATIVE'],
            default=['POSITIVE', 'NEUTRAL', 'NEGATIVE']
        )
        
        if sentiment_filter:
            call_data = call_data[call_data['SENTIMENT_CATEGORY'].isin(sentiment_filter)]
    
    # Render selected page
    if page == "📊 Executive Dashboard":
        show_executive_dashboard(call_data, stats)
    elif page == "👨‍💼 Agent Performance":
        show_agent_performance(call_data)
    elif page == "👤 Customer Insights":
        show_customer_insights(call_data, customer_data)
    elif page == "🗺️ Regional Analysis":
        show_regional_analysis(call_data, customer_data)
    elif page == "🔍 Transcript Search":
        show_transcript_search(call_data)


if __name__ == "__main__":
    main()

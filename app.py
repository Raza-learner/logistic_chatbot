from flask import Flask, render_template, request, jsonify
import mysql.connector
import google.generativeai as genai
import re
import os
from dotenv import load_dotenv

app = Flask(__name__)

# Load environment variables
load_dotenv()
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")  # Get from https://aistudio.google.com/app/apikey
genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel('gemini-1.5-flash')

# Database configuration
DB_CONFIG = {
    'user': 'chatbot_user',
    'password': 'raza@786',
    'host': 'localhost',
    'database': 'admin_db'
}

def get_db_connection():
    return mysql.connector.connect(**DB_CONFIG)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/chat', methods=['POST'])
def chat():
    user_query = request.json.get('query')
    if not user_query:
        return jsonify({'response': 'Please enter a query.'})

    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        # Extract tracking number or admin task request
        tracking_match = re.search(r'TRK\d+', user_query)
        admin_task_match = re.search(r'(show|list)\s+(all\s+)?admin\s+tasks', user_query, re.IGNORECASE)
        db_data = None

        if tracking_match:
            tracking_number = tracking_match.group(0)
            # Query database for customer, shipment details, and tracking logs
            cursor.execute("""
                SELECT c.first_name, c.last_name, c.email, c.phone, c.address,
                       s.tracking_id, s.package_status, s.origin, s.destination, s.weight,
                       s.estimated_delivery, tl.log_id, tl.log_type, tl.log_description, tl.log_time
                FROM customers c
                JOIN shipments s ON c.customer_id = s.customer_id
                LEFT JOIN tracking_logs tl ON s.tracking_id = tl.tracking_id
                WHERE s.tracking_id = %s
                ORDER BY tl.log_time DESC
            """, (tracking_number,))
            results = cursor.fetchall()
            if results:
                tracking_logs = [
                    {
                        'log_id': r['log_id'],
                        'log_type': r['log_type'],
                        'description': r['log_description'],
                        'time': str(r['log_time'])
                    }
                    for r in results if r['log_id']
                ]
                db_data = {
                    'tracking_id': results[0]['tracking_id'],
                    'customer': {
                        'name': f"{results[0]['first_name']} {results[0]['last_name']}",
                        'email': results[0]['email'],
                        'phone': results[0]['phone'],
                        'address': results[0]['address']
                    },
                    'package': {
                        'status': results[0]['package_status'],
                        'origin': results[0]['origin'],
                        'destination': results[0]['destination'],
                        'weight': results[0]['weight'],
                        'estimated_delivery': str(results[0]['estimated_delivery']) if results[0]['estimated_delivery'] else 'N/A'
                    },
                    'tracking_logs': tracking_logs
                }
            else:
                db_data = "No shipment found for this tracking number."
        elif admin_task_match:
            # Query database for all admin tasks
            cursor.execute("""
                SELECT task_id, admin_id, task_description, task_status, created_at, completed_at
                FROM admin_tasks
                ORDER BY created_at DESC
            """)
            results = cursor.fetchall()
            if results:
                db_data = {
                    'admin_tasks': [
                        {
                            'task_id': r['task_id'],
                            'admin_id': r['admin_id'],
                            'description': r['task_description'],
                            'status': r['task_status'],
                            'created_at': str(r['created_at']),
                            'completed_at': str(r['completed_at']) if r['completed_at'] else None
                        }
                        for r in results
                    ]
                }
            else:
                db_data = "No admin tasks found."
        else:
            # Log general queries (for simplicity, assume customer_id=1)
            cursor.execute("INSERT INTO Customer_Queries (customer_id, query_text) VALUES (1, %s)", (user_query,))
            conn.commit()
            db_data = "Query logged. Awaiting response."

        cursor.close()
        conn.close()

        # Generate response using Gemini
        prompt = f"""
        You are a knowledgeable and helpful logistics chatbot for a global shipping company, designed to assist admins with customer and package inquiries and administrative tasks. Respond politely, professionally, and concisely in a human-like tone. Use only the provided database results—do not invent information.

        **Guidelines**:
        - Identify query type (tracking, admin tasks, or general).
        - For tracking queries (e.g., TRK123456789), provide the following in a list format, with each item on a new line:
            Tracking ID: [tracking_id]
            Customer Name: [customer.name]
            Customer Email: [customer.email]
            Customer Phone: [customer.phone]
            Customer Address: [customer.address]
            Package Status: [package.status]
            Origin: [package.origin]
            Destination: [package.destination]
            Weight: [package.weight] kg
            Estimated Delivery Date: [package.estimated_delivery]
            Tracking Logs: List all logs in chronological order (newest to oldest), each as "[time]: [log_type] - [description]"
        - For admin task queries (e.g., "show all admin tasks"), list all tasks in chronological order (newest to oldest), each as:
            Task ID: [task_id], Admin ID: [admin_id], Description: [description], Status: [status], Created: [created_at], Completed: [completed_at]
        - If no data is found, apologize and suggest alternatives (e.g., "I couldn't find that tracking ID. Please double-check or provide more details.").
        - For general queries, acknowledge logging and provide high-level guidance.
        - For actions like modifications, mention escalation.
        - End with: "Is there anything else I can assist with?"

        **User Query**: "{user_query}"
        **Database Results**: {db_data}
        """
        response = model.generate_content(prompt)
        bot_response = response.text.strip()

        return jsonify({'response': bot_response})

    except mysql.connector.Error as err:
        return jsonify({'response': f"Database error: {err}"})
    except Exception as e:
        return jsonify({'response': f"Error: {str(e)}"})

if __name__ == '__main__':
    app.run(debug=True)
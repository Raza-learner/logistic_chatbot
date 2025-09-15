from flask import Flask, render_template, request, jsonify, session
import mysql.connector
import mysql.connector.pooling
import google.generativeai as genai
import re
import os
import secrets
from dotenv import load_dotenv

app = Flask(__name__)
app.secret_key = secrets.token_hex(32)  # Secure random secret key for sessions

# Load environment variables
load_dotenv()
GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")  # Get from https://aistudio.google.com/app/apikey
genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel('gemini-2.5-flash')  # Corrected model name

# Database configuration with pooling for optimization
DB_CONFIG = {
    'user': 'chatbot_user',
    'password': 'raza@786',
    'host': 'localhost',
    'database': 'admin_db'
}
db_pool = mysql.connector.pooling.MySQLConnectionPool(pool_name="mypool", pool_size=5, **DB_CONFIG)

def get_db_connection():
    return db_pool.get_connection()

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/admin_chat', methods=['POST'])
def admin_chat():
    user_query = request.json.get('query')
    if not user_query:
        return jsonify({'response': 'Please enter a query.'})

    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)

        db_data = None
        admin_id = 1  # Hardcoded for simplicity; use authentication in production

        # Get or initialize chat history from session (for LLM context)
        chat_history = session.get('chat_history', [])
        # Limit to last 5 messages
        if len(chat_history) > 5:
            chat_history = chat_history[-5:]

        # Extract tracking number, phone, or email
        tracking_match = re.search(r'TRK\d+', user_query)
        phone_match = re.search(r'\+[\d-]+', user_query)
        email_match = re.search(r'[\w\.-]+@[\w\.-]+\.\w+', user_query)
        query_id_match = re.search(r'query\s*ID\s*(\d+)', user_query, re.IGNORECASE)
        respond_match = re.search(r'respond\s+to\s+query\s*ID\s*(\d+)\s+with\s+(.+)', user_query, re.IGNORECASE)

        # Check for context (last tracking number)
        last_tracking_number = session.get('last_tracking_number')

        if tracking_match:
            tracking_number = tracking_match.group(0)
            session['last_tracking_number'] = tracking_number  # Store in session
            # Query shipment details, tracking updates, shipment logs, customer info, and package details
            cursor.execute("""
                SELECT s.tracking_number, s.current_location, s.status, s.estimated_delivery_date,
                       tu.update_time, tu.location, tu.status_description,
                       sl.log_type, sl.log_description, sl.log_time,
                       c.name, c.email, o.total_weight, o.dimensions, o.destination_address, o.shipping_method
                FROM Shipments s
                LEFT JOIN Tracking_Updates tu ON s.shipment_id = tu.shipment_id
                LEFT JOIN Shipment_Logs sl ON s.tracking_number = sl.tracking_number
                LEFT JOIN Orders o ON s.order_id = o.order_id
                LEFT JOIN Customers c ON o.customer_id = c.customer_id
                WHERE s.tracking_number = %s
                ORDER BY tu.update_time DESC, sl.log_time DESC
            """, (tracking_number,))
            results = cursor.fetchall()
            if results:
                tracking_history = [
                    {'time': str(r['update_time']), 'location': r['location'], 'status': r['status_description']}
                    for r in results if r['status_description']
                ]
                shipment_logs = [
                    {'time': str(r['log_time']), 'type': r['log_type'], 'description': r['log_description']}
                    for r in results if r['log_description']
                ]
                db_data = {
                    'tracking_number': results[0]['tracking_number'],
                    'current_location': results[0]['current_location'],
                    'status': results[0]['status'],
                    'estimated_delivery_date': str(results[0]['estimated_delivery_date']),
                    'customer_name': results[0]['name'],
                    'customer_email': results[0]['email'],
                    'package_weight': str(results[0]['total_weight']),
                    'package_dimensions': results[0]['dimensions'],
                    'destination_address': results[0]['destination_address'],
                    'shipping_method': results[0]['shipping_method'],
                    'tracking_history': tracking_history,
                    'shipment_logs': shipment_logs
                }
                # Log admin action
                cursor.execute("""
                    INSERT INTO Admin_Actions (admin_id, tracking_number, action_type, action_description)
                    VALUES (%s, %s, %s, %s)
                """, (admin_id, tracking_number, 'view', f'Viewed details for {tracking_number}'))
                conn.commit()
            else:
                db_data = "No shipment found for this tracking number."
        elif phone_match or email_match:
            # Query by phone or email
            identifier = phone_match.group(0) if phone_match else email_match.group(0)
            field = 'phone' if phone_match else 'email'
            cursor.execute("""
                SELECT s.tracking_number, s.current_location, s.status, s.estimated_delivery_date,
                       tu.update_time, tu.location, tu.status_description,
                       sl.log_type, sl.log_description, sl.log_time,
                       c.name, c.email, o.total_weight, o.dimensions, o.destination_address, o.shipping_method
                FROM Shipments s
                LEFT JOIN Tracking_Updates tu ON s.shipment_id = tu.shipment_id
                LEFT JOIN Shipment_Logs sl ON s.tracking_number = sl.tracking_number
                LEFT JOIN Orders o ON s.order_id = o.order_id
                LEFT JOIN Customers c ON o.customer_id = c.customer_id
                WHERE c.""" + field + """ = %s
                ORDER BY tu.update_time DESC, sl.log_time DESC
            """, (identifier,))
            results = cursor.fetchall()
            if results:
                tracking_numbers = list(set(r['tracking_number'] for r in results))
                session['last_tracking_number'] = tracking_numbers[0] if tracking_numbers else None  # Store first tracking number
                shipments = []
                for tn in tracking_numbers:
                    tn_results = [r for r in results if r['tracking_number'] == tn]
                    tracking_history = [
                        {'time': str(r['update_time']), 'location': r['location'], 'status': r['status_description']}
                        for r in tn_results if r['status_description']
                    ]
                    shipment_logs = [
                        {'time': str(r['log_time']), 'type': r['log_type'], 'description': r['log_description']}
                        for r in tn_results if r['log_description']
                    ]
                    shipments.append({
                        'tracking_number': tn,
                        'current_location': tn_results[0]['current_location'],
                        'status': tn_results[0]['status'],
                        'estimated_delivery_date': str(tn_results[0]['estimated_delivery_date']),
                        'customer_name': tn_results[0]['name'],
                        'customer_email': tn_results[0]['email'],
                        'package_weight': str(tn_results[0]['total_weight']),
                        'package_dimensions': tn_results[0]['dimensions'],
                        'destination_address': tn_results[0]['destination_address'],
                        'shipping_method': tn_results[0]['shipping_method'],
                        'tracking_history': tracking_history,
                        'shipment_logs': shipment_logs
                    })
                db_data = {'shipments': shipments}
                # Log admin action
                cursor.execute("""
                    INSERT INTO Admin_Actions (admin_id, action_type, action_description)
                    VALUES (%s, %s, %s)
                """, (admin_id, 'view', f'Viewed shipments for {field} {identifier}'))
                conn.commit()
            else:
                db_data = f"No shipments found for {field} {identifier}."
        elif 'status' in user_query.lower() and last_tracking_number:
            # Use last tracking number from session
            cursor.execute("""
                SELECT s.tracking_number, s.current_location, s.status, s.estimated_delivery_date,
                       tu.update_time, tu.location, tu.status_description,
                       sl.log_type, sl.log_description, sl.log_time,
                       c.name, c.email, o.total_weight, o.dimensions, o.destination_address, o.shipping_method
                FROM Shipments s
                LEFT JOIN Tracking_Updates tu ON s.shipment_id = tu.shipment_id
                LEFT JOIN Shipment_Logs sl ON s.tracking_number = sl.tracking_number
                LEFT JOIN Orders o ON s.order_id = o.order_id
                LEFT JOIN Customers c ON o.customer_id = c.customer_id
                WHERE s.tracking_number = %s
                ORDER BY tu.update_time DESC, sl.log_time DESC
            """, (last_tracking_number,))
            results = cursor.fetchall()
            if results:
                tracking_history = [
                    {'time': str(r['update_time']), 'location': r['location'], 'status': r['status_description']}
                    for r in results if r['status_description']
                ]
                shipment_logs = [
                    {'time': str(r['log_time']), 'type': r['log_type'], 'description': r['log_description']}
                    for r in results if r['log_description']
                ]
                db_data = {
                    'tracking_number': results[0]['tracking_number'],
                    'current_location': results[0]['current_location'],
                    'status': results[0]['status'],
                    'estimated_delivery_date': str(results[0]['estimated_delivery_date']),
                    'customer_name': results[0]['name'],
                    'customer_email': results[0]['email'],
                    'package_weight': str(results[0]['total_weight']),
                    'package_dimensions': results[0]['dimensions'],
                    'destination_address': results[0]['destination_address'],
                    'shipping_method': results[0]['shipping_method'],
                    'tracking_history': tracking_history,
                    'shipment_logs': shipment_logs
                }
                # Log admin action
                cursor.execute("""
                    INSERT INTO Admin_Actions (admin_id, tracking_number, action_type, action_description)
                    VALUES (%s, %s, %s, %s)
                """, (admin_id, last_tracking_number, 'view', f'Viewed details for {last_tracking_number} using context'))
                conn.commit()
            else:
                db_data = "No shipment found for the last tracking number."
        elif 'list all shipments' in user_query.lower():
            # List all shipments
            cursor.execute("""
                SELECT s.tracking_number, s.current_location, s.status, s.estimated_delivery_date,
                       c.name, c.email, o.total_weight, o.dimensions, o.destination_address, o.shipping_method
                FROM Shipments s
                LEFT JOIN Orders o ON s.order_id = o.order_id
                LEFT JOIN Customers c ON o.customer_id = c.customer_id
            """)
            results = cursor.fetchall()
            db_data = [
                {
                    'tracking_number': r['tracking_number'],
                    'current_location': r['current_location'],
                    'status': r['status'],
                    'estimated_delivery_date': str(r['estimated_delivery_date']),
                    'customer_name': r['name'],
                    'customer_email': r['email'],
                    'package_weight': str(r['total_weight']),
                    'package_dimensions': r['dimensions'],
                    'destination_address': r['destination_address'],
                    'shipping_method': r['shipping_method']
                } for r in results
            ]
            cursor.execute("""
                INSERT INTO Admin_Actions (admin_id, action_type, action_description)
                VALUES (%s, %s, %s)
            """, (admin_id, 'view', 'Listed all shipments'))
            conn.commit()
        elif 'customer queries' in user_query.lower():
            # List customer queries
            status = 'open' if 'open' in user_query.lower() else 'escalated' if 'escalated' in user_query.lower() else None
            query = """
                SELECT cq.query_id, cq.customer_id, cq.query_text, cq.query_status, cq.created_at, cq.response_text,
                       c.name, c.email
                FROM Customer_Queries cq
                LEFT JOIN Customers c ON cq.customer_id = c.customer_id
            """
            params = []
            if status:
                query += " WHERE cq.query_status = %s"
                params.append(status)
            cursor.execute(query, params)
            results = cursor.fetchall()
            db_data = [
                {
                    'query_id': r['query_id'],
                    'customer_id': r['customer_id'],
                    'customer_name': r['name'],
                    'customer_email': r['email'],
                    'query_text': r['query_text'],
                    'query_status': r['query_status'],
                    'created_at': str(r['created_at']),
                    'response_text': r['response_text']
                } for r in results
            ]
            cursor.execute("""
                INSERT INTO Admin_Actions (admin_id, action_type, action_description)
                VALUES (%s, %s, %s)
            """, (admin_id, 'view', f'Viewed {"all" if not status else status} customer queries'))
            conn.commit()
        elif respond_match:
            # Respond to a customer query
            query_id = respond_match.group(1)
            response_text = respond_match.group(2)
            cursor.execute("""
                UPDATE Customer_Queries
                SET response_text = %s, query_status = %s
                WHERE query_id = %s
            """, (response_text, 'resolved', query_id))
            if cursor.rowcount > 0:
                db_data = f"Query ID {query_id} responded with: {response_text}"
                cursor.execute("""
                    INSERT INTO Admin_Actions (admin_id, action_type, action_description)
                    VALUES (%s, %s, %s)
                """, (admin_id, 'note', f'Responded to query ID {query_id} with: {response_text}'))
                conn.commit()
            else:
                db_data = f"No query found with ID {query_id}."
        elif 'admin actions' in user_query.lower():
            # List recent admin actions
            cursor.execute("""
                SELECT action_id, admin_id, tracking_number, action_type, action_description, action_time
                FROM Admin_Actions
                ORDER BY action_time DESC LIMIT 10
            """)
            results = cursor.fetchall()
            db_data = [
                {
                    'action_id': r['action_id'],
                    'admin_id': r['admin_id'],
                    'tracking_number': r['tracking_number'],
                    'action_type': r['action_type'],
                    'action_description': r['action_description'],
                    'action_time': str(r['action_time'])
                } for r in results
            ]
            cursor.execute("""
                INSERT INTO Admin_Actions (admin_id, action_type, action_description)
                VALUES (%s, %s, %s)
            """, (admin_id, 'view', 'Viewed recent admin actions'))
            conn.commit()
        elif 'update status' in user_query.lower():
            # Update shipment status
            tracking_match = re.search(r'TRK\d+', user_query)
            status_match = re.search(r'to\s+(\w+)', user_query)
            tracking_number = tracking_match.group(0) if tracking_match else last_tracking_number
            if tracking_number and status_match:
                new_status = status_match.group(1)
                cursor.execute("""
                    UPDATE Shipments SET status = %s WHERE tracking_number = %s
                """, (new_status, tracking_number))
                conn.commit()
                db_data = f"Status for {tracking_number} updated to {new_status}."
                session['last_tracking_number'] = tracking_number  # Update session
                cursor.execute("""
                    INSERT INTO Admin_Actions (admin_id, tracking_number, action_type, action_description)
                    VALUES (%s, %s, %s, %s)
                """, (admin_id, tracking_number, 'update_status', f'Updated status to {new_status}'))
                conn.commit()
            else:
                db_data = "Please provide a valid tracking number and status, or use the last tracking number."
        else:
            # Log general query
            cursor.execute("""
                INSERT INTO Admin_Actions (admin_id, action_type, action_description)
                VALUES (%s, %s, %s)
            """, (admin_id, 'note', f'General query: {user_query}'))
            conn.commit()
            db_data = "Query logged for review."

        cursor.close()
        conn.close()

        # Generate response using Gemini
        prompt = """
        You are a knowledgeable and helpful logistics admin chatbot for a global shipping company. Your goal is to assist admins with managing shipments, customer queries, and system logs. Respond politely, professionally, and concisely in a human-like tone. Use only the provided database results—do not invent information.

        **Guidelines**:
        - Do not make rendom format , please maintain one format.
        - Read "{user_query}" properly and give answer that much ask, do not give extra info. 
        - Maintain context: If a tracking number was used previously, use it for queries like "status" unless a new tracking number, phone, or email is provided. Refer to chat history for previous context.
        - Identify query type (tracking, phone/email lookup, list shipments, customer queries, respond to query, admin actions, status update, general).
        - For tracking queries (e.g., TRK78901 or last tracking number), provide in a list format, each item on a new line:
          - Tracking Number: [tracking_number]
          - Current Status: [status]
          - Current Location: [current_location]
          - Estimated Delivery Date: [estimated_delivery_date]
          - Customer Name: [customer_name]
          - Customer Email: [customer_email]
          - Package Weight: [package_weight]
          - Package Dimensions: [package_dimensions]
          - Destination Address: [destination_address]
        - Shipping Method: [shipping_method]
        - Tracking Updates: List all customer-facing status changes in chronological order (oldest to newest), each as "[time]: [location] - [status]".
        - Shipment Logs: List all internal system notes, warnings, or errors in chronological order (oldest to newest), each as "[time]: [type] - [description]".
        - For phone or email queries, list all associated shipments in the same list format, grouping by tracking number.
        - For listing shipments, provide a summary of all shipments (tracking number, status, location, customer name, email, weight, dimensions).
        - For customer queries, list details (ID, customer name, email, query text, status, response if any) in a list format, each item on a new line.
        - For responding to queries (e.g., "Respond to query ID X with Y"), confirm the response and status update (resolved).
        - For admin actions, list recent actions (ID, admin ID, tracking number, type, description, time) in a list format.
        - For status updates, confirm the update or request clarification if invalid, using the last tracking number if none provided.
        - If no data is found, apologize and suggest alternatives.
        - Log all actions in the database.
        - Do not hallucinate.
        - Previous Chat History: {chat_history}

        **User Query**: "{user_query}"
        **Database Results**: {db_data}
        """
        response = model.generate_content(prompt.format(user_query=user_query, db_data=db_data, chat_history=chat_history))
        bot_response = response.text.strip()

        # Update chat history in session
        chat_history.append({'query': user_query, 'response': bot_response})
        session['chat_history'] = chat_history

        return jsonify({'response': bot_response})

    except mysql.connector.Error as err:
        return jsonify({'response': f"Database error: {err}"})
    except Exception as e:
        return jsonify({'response': f"Error: {str(e)}"})

if __name__ == '__main__':
    app.run(debug=True)
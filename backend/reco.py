from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('./Recommendation#3', methods=['GET'])
def recommend():
    user_id = int(request.args.get('user_id'))
    top_n = int(request.args.get('top_n', 10))
    
    recommendations = hybrid_recommendations(user_id, top_n)
    return jsonify(recommendations.to_dict(orient='records'))

if __name__ == '__main__':
    app.run(debug=True)

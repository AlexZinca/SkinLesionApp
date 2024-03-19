from flask import Flask, request, jsonify
import io
from PIL import Image
from prediction import predict_image_class

app = Flask(__name__)

@app.route('/predict', methods=['POST'])
def predict():
    if 'file' not in request.files:
        return 'No file part', 400

    file = request.files['file']
    if file.filename == '':
        return 'No selected file', 400

    if file:
        image_bytes = file.read()
        image = Image.open(io.BytesIO(image_bytes))
        prediction = predict_image_class(image)
        return jsonify(message=prediction)

if __name__ == '_main_':
    app.run(debug=True, host='0.0.0.0')
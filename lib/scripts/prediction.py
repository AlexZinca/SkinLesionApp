import torch
import torch.nn as nn
from torchvision import transforms
from PIL import Image

# Define the same SimpleCNN class from your training script
class SimpleCNN(nn.Module):
    def _init_(self, num_classes):
        super(SimpleCNN, self)._init_()
        self.conv1 = nn.Conv2d(3, 16, 3, padding=1)
        self.conv2 = nn.Conv2d(16, 32, 3, padding=1)
        self.conv3 = nn.Conv2d(32, 64, 3, padding=1)
        self.pool = nn.MaxPool2d(2, 2)
        self.dropout = nn.Dropout(0.4)
        self.fc1 = nn.Linear(64 * 18 * 18, 500)
        self.fc2 = nn.Linear(500, num_classes)
        self.relu = nn.ReLU()

    def forward(self, x):
        x = self.pool(self.relu(self.conv1(x)))
        x = self.dropout(x)
        x = self.pool(self.relu(self.conv2(x)))
        x = self.dropout(x)
        x = self.pool(self.relu(self.conv3(x)))
        x = self.dropout(x)
        x = x.view(-1, 64 * 18 * 18)
        x = self.relu(self.fc1(x))
        x = self.dropout(x)
        x = self.fc2(x)
        return x

def predict_image_class2():
    image_path = "C:/Users/Alex/Desktop/Licenta/Dataset/Mel/ISIC_0026115.jpg"
    model_path = "/Users/alexandruzinca/AndroidStudioProjects/simple_cnn_model2.pth"
    num_classes = 7  # Your number of classes

    # Initialize the model
    model = SimpleCNN(num_classes)

    # Load the trained model weights
    model.load_state_dict(torch.load(model_path, map_location=torch.device('cpu')))
    model.eval()  # Set the model to evaluation mode

    # Define image transforms
    image_transforms = transforms.Compose([
        transforms.Resize(256),
        transforms.CenterCrop(150),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])

    # Load and transform the image
    image = Image.open(image_path).convert('RGB')
    image = image_transforms(image).unsqueeze(0)  # Add batch dimension

    # Predict the class
    output = model(image)
    _, predicted = torch.max(output, 1)

    return predicted.item()

# The below lines can be used for direct script testing, but should be commented out or removed when importing this as a module.
# image_path = "path/to/your/image.jpg"
# model_path = "path/to/your/model.pth"
# print(predict_image_class(image_path, model_path))
# Modify this function to accept an image argument
def predict_image_class(image):
    model_path = "/Users/alexandruzinca/AndroidStudioProjects/simple_cnn_model2.pth"
    num_classes = 7

    model = SimpleCNN(num_classes)
    model.load_state_dict(torch.load(model_path, map_location=torch.device('cpu')))
    model.eval()

    # Assume the passed image is a PIL Image, no need to load from path
    image_transforms = transforms.Compose([
        transforms.Resize(256),
        transforms.CenterCrop(150),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])

    image = image.convert('RGB')
    image = image_transforms(image).unsqueeze(0)

    output = model(image)
    _, predicted = torch.max(output, 1)

    return predicted.item()
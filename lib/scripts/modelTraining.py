import os
import torch
import torch.nn as nn
import torch.optim as optim
from torchvision import datasets, models, transforms
import matplotlib.pyplot as plt

# Setup directories
base_dir = 'C:/Users/Alex/Desktop/Licenta2/'
train_dir = os.path.join(base_dir, 'Dataset')  # Training data
validation_dir = os.path.join(base_dir, 'Testset')  # Validation data

# Define transformations for training and validation sets
train_transforms = transforms.Compose([
    transforms.RandomResizedCrop(150),
    transforms.RandomHorizontalFlip(),
    transforms.RandomRotation(45),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
])

val_transforms = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(150),
    transforms.ToTensor(),
    transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
])

# Load data
train_dataset = datasets.ImageFolder(train_dir, transform=train_transforms)
val_dataset = datasets.ImageFolder(validation_dir, transform=val_transforms)

train_loader = torch.utils.data.DataLoader(train_dataset, batch_size=3, shuffle=True)
val_loader = torch.utils.data.DataLoader(val_dataset, batch_size=3)

# Define a simple CNN model
# Assuming the number of classes is inferred from the train dataset
num_classes = len(train_dataset.classes)

print(num_classes)


class SimpleCNN(nn.Module):
    def __init__(self, num_classes):
        super(SimpleCNN, self).__init__()
        self.conv1 = nn.Conv2d(3, 16, 3, padding=1)
        self.conv2 = nn.Conv2d(16, 32, 3, padding=1)
        self.conv3 = nn.Conv2d(32, 64, 3, padding=1)
        self.pool = nn.MaxPool2d(2, 2)
        self.dropout = nn.Dropout(0.4)
        # Adjust the following line if your input size changes
        self.fc1 = nn.Linear(64 * 18 * 18, 500)
        self.fc2 = nn.Linear(500, num_classes)  # Output layer now dynamically uses num_classes
        self.relu = nn.ReLU()

    def forward(self, x):
        x = self.pool(self.relu(self.conv1(x)))
        x = self.dropout(x)
        x = self.pool(self.relu(self.conv2(x)))
        x = self.dropout(x)
        x = self.pool(self.relu(self.conv3(x)))
        x = self.dropout(x)
        x = x.view(-1, 64 * 18 * 18)  # Flatten the output for the dense layer
        x = self.relu(self.fc1(x))
        x = self.dropout(x)
        x = self.fc2(x)
        return x

# Initialize the model with the number of classes
model = SimpleCNN(num_classes)


# Initialize model, loss, and optimize
criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=0.001)

# Training loop
num_epochs = 100
for epoch in range(num_epochs):
    model.train()
    running_loss = 0.0
    for inputs, labels in train_loader:
        optimizer.zero_grad()
        outputs = model(inputs)
        loss = criterion(outputs, labels)
        loss.backward()
        optimizer.step()
        running_loss += loss.item()

    model.eval()
    val_loss = 0.0
    correct = 0
    total = 0
    with torch.no_grad():
        for inputs, labels in val_loader:
            outputs = model(inputs)
            loss = criterion(outputs, labels)
            val_loss += loss.item()
            _, predicted = torch.max(outputs.data, 1)
            total += labels.size(0)
            correct += (predicted == labels).sum().item()

    print(f'Epoch {epoch+1}, Loss: {running_loss / len(train_loader)}, '
          f'Validation Loss: {val_loss / len(val_loader)}, '
          f'Accuracy: {100 * correct / total}%')

print('Finished Training')

# At the end of your training loop, after printing "Finished Training"
model_save_path = 'C:/Users/Alex/Desktop/Licenta2/simple_cnn_model2.pth'
torch.save(model.state_dict(), model_save_path)
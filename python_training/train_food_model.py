"""
Custom Food Recognition Model Training Script
Trains a deep learning model specifically for Indian and global foods
"""

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
import numpy as np
import os
import json

class FoodRecognitionTrainer:
    def __init__(self, img_size=224, num_classes=101):
        """
        Initialize trainer for food recognition
        Args:
            img_size: Input image size (224x224 for MobileNetV2)
            num_classes: Number of food categories
        """
        self.img_size = img_size
        self.num_classes = num_classes
        self.model = None
        
    def create_model(self):
        """
        Create MobileNetV2-based model optimized for mobile deployment
        """
        # Load pre-trained MobileNetV2 (trained on ImageNet)
        base_model = MobileNetV2(
            input_shape=(self.img_size, self.img_size, 3),
            include_top=False,
            weights='imagenet'
        )
        
        # Freeze base model initially
        base_model.trainable = False
        
        # Add custom classification head
        model = models.Sequential([
            base_model,
            layers.GlobalAveragePooling2D(),
            layers.Dropout(0.3),
            layers.Dense(512, activation='relu'),
            layers.BatchNormalization(),
            layers.Dropout(0.4),
            layers.Dense(256, activation='relu'),
            layers.BatchNormalization(),
            layers.Dropout(0.3),
            layers.Dense(self.num_classes, activation='softmax')
        ])
        
        # Compile model
        model.compile(
            optimizer=keras.optimizers.Adam(learning_rate=0.001),
            loss='categorical_crossentropy',
            metrics=['accuracy', 'top_k_categorical_accuracy']
        )
        
        self.model = model
        return model
    
    def fine_tune_model(self):
        """
        Unfreeze and fine-tune the base model
        """
        if self.model is None:
            raise ValueError("Model not created. Call create_model() first.")
        
        # Unfreeze the base model
        base_model = self.model.layers[0]
        base_model.trainable = True
        
        # Freeze early layers, fine-tune later layers
        for layer in base_model.layers[:100]:
            layer.trainable = False
        
        # Recompile with lower learning rate for fine-tuning
        self.model.compile(
            optimizer=keras.optimizers.Adam(learning_rate=0.0001),
            loss='categorical_crossentropy',
            metrics=['accuracy', 'top_k_categorical_accuracy']
        )
    
    def create_data_generators(self, train_dir, val_dir, batch_size=32):
        """
        Create data generators with augmentation
        """
        # Training data augmentation
        train_datagen = ImageDataGenerator(
            rescale=1./255,
            rotation_range=30,
            width_shift_range=0.2,
            height_shift_range=0.2,
            shear_range=0.2,
            zoom_range=0.2,
            horizontal_flip=True,
            brightness_range=[0.8, 1.2],
            fill_mode='nearest'
        )
        
        # Validation data (only rescaling)
        val_datagen = ImageDataGenerator(rescale=1./255)
        
        train_generator = train_datagen.flow_from_directory(
            train_dir,
            target_size=(self.img_size, self.img_size),
            batch_size=batch_size,
            class_mode='categorical',
            shuffle=True
        )
        
        val_generator = val_datagen.flow_from_directory(
            val_dir,
            target_size=(self.img_size, self.img_size),
            batch_size=batch_size,
            class_mode='categorical',
            shuffle=False
        )
        
        return train_generator, val_generator
    
    def train(self, train_generator, val_generator, epochs=50):
        """
        Train the model with callbacks
        """
        if self.model is None:
            self.create_model()
        
        # Callbacks
        callbacks = [
            keras.callbacks.ModelCheckpoint(
                'models/best_food_model.h5',
                save_best_only=True,
                monitor='val_accuracy',
                mode='max'
            ),
            keras.callbacks.EarlyStopping(
                monitor='val_loss',
                patience=10,
                restore_best_weights=True
            ),
            keras.callbacks.ReduceLROnPlateau(
                monitor='val_loss',
                factor=0.5,
                patience=5,
                min_lr=1e-7
            ),
            keras.callbacks.TensorBoard(
                log_dir='logs',
                histogram_freq=1
            )
        ]
        
        # Initial training
        print("Phase 1: Training with frozen base model...")
        history1 = self.model.fit(
            train_generator,
            epochs=epochs//2,
            validation_data=val_generator,
            callbacks=callbacks
        )
        
        # Fine-tuning
        print("\nPhase 2: Fine-tuning with unfrozen layers...")
        self.fine_tune_model()
        history2 = self.model.fit(
            train_generator,
            epochs=epochs//2,
            validation_data=val_generator,
            callbacks=callbacks
        )
        
        return history1, history2
    
    def convert_to_tflite(self, output_path='models/food_model.tflite'):
        """
        Convert model to TensorFlow Lite for mobile deployment
        """
        if self.model is None:
            raise ValueError("No model to convert")
        
        # Convert to TFLite with optimizations
        converter = tf.lite.TFLiteConverter.from_keras_model(self.model)
        
        # Optimizations for mobile
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        converter.target_spec.supported_types = [tf.float16]
        
        # Convert
        tflite_model = converter.convert()
        
        # Save
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        with open(output_path, 'wb') as f:
            f.write(tflite_model)
        
        print(f"TFLite model saved to {output_path}")
        
        # Get model size
        size_mb = os.path.getsize(output_path) / (1024 * 1024)
        print(f"Model size: {size_mb:.2f} MB")
        
    def save_labels(self, class_indices, output_path='models/labels.json'):
        """
        Save class labels for inference
        """
        # Invert the dictionary (index -> label)
        labels = {v: k for k, v in class_indices.items()}
        
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        with open(output_path, 'w') as f:
            json.dump(labels, f, indent=2)
        
        print(f"Labels saved to {output_path}")


# FOOD-101 Dataset Configuration
FOOD_CATEGORIES = [
    # Indian Foods
    'samosa', 'pakora', 'biryani', 'dosa', 'idli', 'vada',
    'roti', 'naan', 'paratha', 'dal', 'paneer_tikka', 'butter_chicken',
    'tandoori_chicken', 'gulab_jamun', 'jalebi', 'rasgulla',
    
    # Western Foods
    'pizza', 'hamburger', 'hot_dog', 'sandwich', 'french_fries',
    'fried_chicken', 'steak', 'spaghetti', 'lasagna', 'tacos',
    
    # Asian Foods
    'sushi', 'ramen', 'pad_thai', 'spring_rolls', 'dumplings',
    'fried_rice', 'pho', 'bibimbap', 'tempura',
    
    # Common Foods
    'eggs', 'omelette', 'pancakes', 'waffles', 'salad',
    'soup', 'rice', 'bread', 'pasta', 'chicken_curry',
    
    # Desserts & Snacks
    'ice_cream', 'cake', 'donuts', 'cookies', 'brownies',
    'apple_pie', 'cheesecake', 'chocolate_cake',
    
    # Breakfast
    'breakfast_burrito', 'french_toast', 'bagel', 'muffin',
    'croissant', 'toast', 'cereal', 'yogurt',
    
    # Fruits & Vegetables
    'apple', 'banana', 'orange', 'grapes', 'watermelon',
    'strawberries', 'blueberries', 'mango', 'pineapple',
    'broccoli', 'carrots', 'tomato', 'cucumber', 'lettuce',
    
    # Beverages (visible in photos)
    'coffee', 'tea', 'smoothie', 'juice', 'milkshake',
    
    # Others
    'burrito', 'quesadilla', 'nachos', 'falafel', 'hummus'
]

def main():
    """
    Main training script
    """
    print("=" * 60)
    print("CalorieWala Custom Food Recognition Model Training")
    print("=" * 60)
    
    # Configuration
    IMG_SIZE = 224
    NUM_CLASSES = len(FOOD_CATEGORIES)
    BATCH_SIZE = 32
    EPOCHS = 50
    
    # Paths (update these to your dataset location)
    TRAIN_DIR = 'datasets/food101/train'
    VAL_DIR = 'datasets/food101/validation'
    
    print(f"\nTraining Configuration:")
    print(f"- Image Size: {IMG_SIZE}x{IMG_SIZE}")
    print(f"- Number of Classes: {NUM_CLASSES}")
    print(f"- Batch Size: {BATCH_SIZE}")
    print(f"- Epochs: {EPOCHS}")
    print(f"- Categories: {', '.join(FOOD_CATEGORIES[:10])}... (+{NUM_CLASSES-10} more)")
    
    # Initialize trainer
    trainer = FoodRecognitionTrainer(img_size=IMG_SIZE, num_classes=NUM_CLASSES)
    
    # Create model
    print("\n" + "="*60)
    print("Creating Model Architecture...")
    print("="*60)
    model = trainer.create_model()
    model.summary()
    
    # Note: You need to prepare the dataset first
    print("\n" + "="*60)
    print("DATASET PREPARATION REQUIRED")
    print("="*60)
    print("\nTo train this model, you need to:")
    print("1. Download Food-101 dataset: https://data.vision.ee.ethz.ch/cvl/food-101.tar.gz")
    print("2. Or use Kaggle Food-101: https://www.kaggle.com/datasets/dansbecker/food-101")
    print("3. Extract to 'datasets/food101/' directory")
    print("4. Organize as: datasets/food101/train/<category>/<images>")
    print("5. Run this script again")
    print("\nAlternatively, you can:")
    print("- Collect your own images (100+ per category)")
    print("- Use image scraping tools (ensure legal compliance)")
    print("- Augment existing datasets with Indian food images")
    
    # Check if dataset exists
    if os.path.exists(TRAIN_DIR) and os.path.exists(VAL_DIR):
        print("\n" + "="*60)
        print("Starting Training...")
        print("="*60)
        
        # Create data generators
        train_gen, val_gen = trainer.create_data_generators(
            TRAIN_DIR, VAL_DIR, BATCH_SIZE
        )
        
        # Save class indices
        trainer.save_labels(train_gen.class_indices)
        
        # Train model
        history1, history2 = trainer.train(train_gen, val_gen, EPOCHS)
        
        # Convert to TFLite
        print("\n" + "="*60)
        print("Converting to TensorFlow Lite...")
        print("="*60)
        trainer.convert_to_tflite()
        
        print("\n" + "="*60)
        print("TRAINING COMPLETE!")
        print("="*60)
        print("\nModel files created:")
        print("- models/food_model.tflite (for Flutter app)")
        print("- models/labels.json (food categories)")
        print("- models/best_food_model.h5 (Keras model)")
        
        print("\n" + "="*60)
        print("INTEGRATION STEPS:")
        print("="*60)
        print("1. Copy food_model.tflite to: assets/ml_models/")
        print("2. Copy labels.json to: assets/ml_models/")
        print("3. Add to pubspec.yaml:")
        print("   assets:")
        print("     - assets/ml_models/")
        print("4. Use tflite_flutter package for inference")
        print("5. Update local_food_recognizer.dart to use custom model")
        
    else:
        print("\n⚠️  Dataset directories not found. Model created but not trained.")
        print("Download and prepare dataset, then run again.")

if __name__ == "__main__":
    main()

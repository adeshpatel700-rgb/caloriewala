# Training Custom Food Recognition Model for CalorieWala

## Overview
This guide helps you train a custom deep learning model specifically for food recognition, optimized for Indian and global cuisines.

## Quick Start

### 1. Install Python Dependencies
```bash
cd python_training
pip install -r requirements.txt
```

### 2. Download Dataset
You have three options:

#### Option A: Food-101 Dataset (Recommended)
- **Download**: https://data.vision.ee.ethz.ch/cvl/food-101.tar.gz
- **Size**: ~5GB
- **Classes**: 101 food categories
- **Images**: 101,000 images (1,000 per class)

```bash
wget https://data.vision.ee.ethz.ch/cvl/food-101.tar.gz
tar -xzf food-101.tar.gz
```

#### Option B: Kaggle Food-101
- **URL**: https://www.kaggle.com/datasets/dansbecker/food-101
- Use Kaggle CLI or download manually

#### Option C: Custom Dataset
Collect your own images:
- Minimum 100 images per food category
- Include Indian foods: roti, dal, biryani, samosa, etc.
- Ensure variety in lighting, angles, portions

### 3. Organize Dataset
Structure your dataset as:
```
datasets/
└── food101/
    ├── train/
    │   ├── samosa/
    │   │   ├── img1.jpg
    │   │   └── img2.jpg
    │   ├── biryani/
    │   └── pizza/
    └── validation/
        ├── samosa/
        ├── biryani/
        └── pizza/
```

**Split**: 80% training, 20% validation

### 4. Train the Model
```bash
python train_food_model.py
```

**Training Time**:
- GPU (NVIDIA): 2-4 hours
- CPU: 12-24 hours

**Hardware Requirements**:
- RAM: 8GB minimum (16GB recommended)
- Storage: 10GB free space
- GPU: Optional but highly recommended

### 5. Monitor Training
```bash
tensorboard --logdir=logs
```
Open browser at http://localhost:6006

## Model Architecture

### Base Model: MobileNetV2
- **Why**: Optimized for mobile devices
- **Size**: ~14MB after conversion
- **Speed**: Fast inference on mobile
- **Accuracy**: ~85% top-1, ~95% top-5

### Custom Head:
```
GlobalAveragePooling2D
└── Dropout(0.3)
    └── Dense(512, relu)
        └── BatchNormalization
            └── Dropout(0.4)
                └── Dense(256, relu)
                    └── BatchNormalization
                        └── Dropout(0.3)
                            └── Dense(num_classes, softmax)
```

### Training Strategy:
1. **Phase 1**: Frozen base, train head (25 epochs)
2. **Phase 2**: Fine-tune last layers (25 epochs)

### Data Augmentation:
- Rotation: ±30°
- Shift: ±20%
- Zoom: ±20%
- Brightness: ±20%
- Horizontal flip

## Integration with Flutter App

### 1. Add TFLite Package
In `pubspec.yaml`:
```yaml
dependencies:
  tflite_flutter: ^0.10.4
```

### 2. Copy Model Files
```bash
cp models/food_model.tflite ../assets/ml_models/
cp models/labels.json ../assets/ml_models/
```

Update `pubspec.yaml`:
```yaml
assets:
  - assets/ml_models/food_model.tflite
  - assets/ml_models/labels.json
```

### 3. Update Recognizer Code
See `improved_local_food_recognizer.dart` for implementation

### 4. Rebuild App
```bash
cd ..
flutter pub get
flutter build apk --release --no-shrink
```

## Expected Results

### Performance Metrics:
- **Top-1 Accuracy**: 80-85%
- **Top-5 Accuracy**: 93-97%
- **Inference Time**: 50-200ms per image
- **Model Size**: 12-15MB (TFLite)

### Improvements Over ML Kit:
- **Specificity**: Recognizes exact dishes (pasta vs. general food)
- **Indian Foods**: Better recognition of regional dishes
- **Confidence**: More reliable confidence scores
- **Portions**: Can detect portion sizes with training

## Advanced: Adding New Categories

### 1. Collect Images
- Minimum 100 images per new category
- Diverse: angles, lighting, portions, presentations

### 2. Add to Training Script
Edit `train_food_model.py`:
```python
FOOD_CATEGORIES = [
    # ... existing categories
    'new_food_category',
    'another_food',
]
```

### 3. Retrain Model
```bash
python train_food_model.py
```

### 4. Update App
Copy new model to Flutter app and rebuild

## Troubleshooting

### Out of Memory
- Reduce `BATCH_SIZE` from 32 to 16 or 8
- Use smaller `IMG_SIZE` (224 → 160)
- Close other applications

### Low Accuracy
- Train longer (increase `EPOCHS`)
- Add more training data
- Check data quality (blur, mislabeled images)
- Increase data augmentation

### Slow Training
- Use GPU (CUDA-enabled TensorFlow)
- Reduce image size
- Use fewer categories initially

### Model Too Large
- Increase quantization (float32 → float16 → int8)
- Use smaller base model (MobileNetV2 → MobileNetV3-Small)

## Production Considerations

### Before Deployment:
1. **Test thoroughly** with real user images
2. **Benchmark performance** on target devices
3. **A/B test** against ML Kit baseline
4. **Monitor** inference times and crashes
5. **Fallback** to text input if confidence < 60%

### Continuous Improvement:
1. Collect failed predictions from users
2. Add to training dataset
3. Retrain monthly/quarterly
4. Version models (v1.0, v1.1, etc.)
5. Allow user feedback on predictions

## Cost Considerations

### Training Costs:
- **Local GPU**: Free (electricity only)
- **Google Colab**: Free (with limits)
- **AWS/GCP**: $0.50-2.00 per training session

### Inference Costs:
- **On-device**: FREE (no API calls)
- **Cloud API**: $1-3 per 1000 images

### Storage:
- **Model file**: 15MB added to APK
- **Dataset**: 5-10GB during training (delete after)

## Resources

### Datasets:
- Food-101: https://www.vision.ee.ethz.ch/datasets_extra/food-101/
- Food-11: https://www.epfl.ch/labs/mmspg/downloads/food-image-datasets/
- Indian Food: https://www.kaggle.com/datasets/aroraumang/indian-food-101
- Recipe1M: http://pic2recipe.csail.mit.edu/

### Papers:
- MobileNetV2: https://arxiv.org/abs/1801.04381
- Food Recognition: https://arxiv.org/abs/1606.05675

### Tools:
- TensorFlow Lite: https://www.tensorflow.org/lite
- TFLite Flutter: https://pub.dev/packages/tflite_flutter
- Kaggle Notebooks: https://www.kaggle.com/

## Support

For issues with:
- **Training script**: Open GitHub issue
- **Dataset preparation**: Check Food-101 documentation
- **Flutter integration**: See `improved_local_food_recognizer.dart`
- **Performance**: Profile with TensorFlow Lite benchmark tool

---

**Note**: Training a custom model is optional. The app works with ML Kit out of the box. Custom training provides better accuracy for specific use cases.

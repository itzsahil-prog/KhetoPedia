"""
Model Evaluation Script for Khetopedia ML Pipeline
Evaluates trained models with comprehensive metrics and visualizations
"""
import argparse
import json
import sys
import time
from pathlib import Path
from typing import Dict, List, Tuple

import torch
import torch.nn as nn
from torch.utils.data import DataLoader
from torchvision import models, transforms
from torchvision.datasets import ImageFolder
from tqdm import tqdm
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import (
    confusion_matrix, classification_report, 
    accuracy_score, precision_recall_fscore_support
)

# Add parent directory to path
sys.path.append(str(Path(__file__).parent.parent))


def load_model_and_metadata(model_path: Path, device: torch.device) -> Tuple[nn.Module, Dict]:
    """
    Load trained model and its metadata.
    
    Returns:
        Tuple of (model, metadata_dict)
    """
    print(f"Loading model from: {model_path}")
    
    # Try to load metadata
    metadata_path = model_path.parent / model_path.name.replace('.pth', '_metadata.json')
    metadata = {}
    
    if metadata_path.exists():
        with open(metadata_path, 'r', encoding='utf-8') as f:
            metadata = json.load(f)
        print(f"Metadata loaded from: {metadata_path}")
    else:
        print("Warning: Metadata file not found, using defaults")
    
    # Load model
    architecture = metadata.get('architecture', 'resnet50')
    num_classes = metadata.get('num_classes', 38)
    
    if architecture == 'resnet50':
        model = models.resnet50(weights=None)
        model.fc = nn.Linear(model.fc.in_features, num_classes)
    elif architecture == 'resnet101':
        model = models.resnet101(weights=None)
        model.fc = nn.Linear(model.fc.in_features, num_classes)
    elif architecture == 'efficientnet_b0':
        model = models.efficientnet_b0(weights=None)
        model.classifier[1] = nn.Linear(model.classifier[1].in_features, num_classes)
    else:
        raise ValueError(f"Unsupported architecture: {architecture}")
    
    # Load weights
    state_dict = torch.load(model_path, map_location=device)
    
    # Handle checkpoint format vs raw state dict
    if isinstance(state_dict, dict) and 'model_state_dict' in state_dict:
        model.load_state_dict(state_dict['model_state_dict'])
        print("Loaded from checkpoint format")
    else:
        model.load_state_dict(state_dict)
        print("Loaded from state dict format")
    
    model = model.to(device)
    model.eval()
    
    print(f"Model loaded: {architecture} with {num_classes} classes")
    
    return model, metadata


def get_data_transform() -> transforms.Compose:
    """Get validation data transform (no augmentation)."""
    return transforms.Compose([
        transforms.Resize(256),
        transforms.CenterCrop(224),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406],
                           std=[0.229, 0.224, 0.225])
    ])


def load_test_dataset(dataset_path: Path, split: str = 'test') -> Tuple[ImageFolder, List[str]]:
    """Load test/validation dataset."""
    test_path = dataset_path / split
    
    # Try alternate split names
    if not test_path.exists():
        alternates = ['valid', 'test', 'val']
        for alt in alternates:
            alt_path = dataset_path / alt
            if alt_path.exists():
                test_path = alt_path
                split = alt
                break
    
    if not test_path.exists():
        raise ValueError(f"Test data not found at {test_path}")
    
    print(f"Loading test data from: {test_path}")
    transform = get_data_transform()
    dataset = ImageFolder(str(test_path), transform=transform)
    
    print(f"Test dataset loaded: {len(dataset)} samples, {len(dataset.classes)} classes")
    
    return dataset, dataset.classes


def evaluate_model(model: nn.Module, dataloader: DataLoader, 
                  device: torch.device) -> Dict:
    """
    Run full evaluation on test set.
    
    Returns:
        Dictionary with predictions, labels, and probabilities
    """
    model.eval()
    
    all_predictions = []
    all_labels = []
    all_probabilities = []
    
    print("\nRunning inference on test set...")
    
    with torch.no_grad():
        for inputs, labels in tqdm(dataloader):
            inputs = inputs.to(device)
            labels = labels.to(device)
            
            outputs = model(inputs)
            probabilities = torch.nn.functional.softmax(outputs, dim=1)
            _, predicted = outputs.max(1)
            
            all_predictions.extend(predicted.cpu().numpy())
            all_labels.extend(labels.cpu().numpy())
            all_probabilities.extend(probabilities.cpu().numpy())
    
    return {
        'predictions': np.array(all_predictions),
        'labels': np.array(all_labels),
        'probabilities': np.array(all_probabilities)
    }


def compute_metrics(predictions: np.ndarray, labels: np.ndarray,
                   probabilities: np.ndarray, class_names: List[str]) -> Dict:
    """Compute comprehensive evaluation metrics."""
    
    # Overall accuracy
    overall_acc = accuracy_score(labels, predictions)
    
    # Top-3 accuracy
    top3_preds = np.argsort(probabilities, axis=1)[:, -3:]
    top3_acc = np.mean([labels[i] in top3_preds[i] for i in range(len(labels))])
    
    # Top-5 accuracy (if enough classes)
    if len(class_names) >= 5:
        top5_preds = np.argsort(probabilities, axis=1)[:, -5:]
        top5_acc = np.mean([labels[i] in top5_preds[i] for i in range(len(labels))])
    else:
        top5_acc = None
    
    # Per-class metrics
    precision, recall, f1, support = precision_recall_fscore_support(
        labels, predictions, average=None, zero_division=0
    )
    
    # Macro averages
    precision_macro, recall_macro, f1_macro, _ = precision_recall_fscore_support(
        labels, predictions, average='macro', zero_division=0
    )
    
    # Weighted averages
    precision_weighted, recall_weighted, f1_weighted, _ = precision_recall_fscore_support(
        labels, predictions, average='weighted', zero_division=0
    )
    
    metrics = {
        'overall_accuracy': float(overall_acc),
        'top3_accuracy': float(top3_acc),
        'top5_accuracy': float(top5_acc) if top5_acc is not None else None,
        'precision_macro': float(precision_macro),
        'recall_macro': float(recall_macro),
        'f1_macro': float(f1_macro),
        'precision_weighted': float(precision_weighted),
        'recall_weighted': float(recall_weighted),
        'f1_weighted': float(f1_weighted),
        'per_class_metrics': []
    }
    
    # Per-class details
    for i, class_name in enumerate(class_names):
        metrics['per_class_metrics'].append({
            'class': class_name,
            'precision': float(precision[i]),
            'recall': float(recall[i]),
            'f1': float(f1[i]),
            'support': int(support[i]),
            'accuracy': float(np.sum((predictions == i) & (labels == i)) / max(np.sum(labels == i), 1))
        })
    
    return metrics


def plot_confusion_matrix(cm: np.ndarray, class_names: List[str], 
                         output_path: Path, normalize: bool = True) -> None:
    """Plot and save confusion matrix."""
    if normalize:
        cm = cm.astype('float') / cm.sum(axis=1)[:, np.newaxis]
        fmt = '.2f'
        title = 'Normalized Confusion Matrix'
    else:
        fmt = 'd'
        title = 'Confusion Matrix'
    
    # For large number of classes, create a bigger figure
    fig_size = max(12, len(class_names) * 0.4)
    plt.figure(figsize=(fig_size, fig_size))
    
    # Use smaller font for many classes
    font_size = max(6, min(10, 120 / len(class_names)))
    
    sns.heatmap(cm, annot=len(class_names) <= 20, fmt=fmt, cmap='Blues',
                xticklabels=class_names, yticklabels=class_names,
                cbar_kws={'label': 'Proportion' if normalize else 'Count'},
                square=True, linewidths=0.5 if len(class_names) <= 20 else 0)
    
    plt.title(title, fontsize=14, pad=20)
    plt.ylabel('True Label', fontsize=12)
    plt.xlabel('Predicted Label', fontsize=12)
    plt.xticks(rotation=45, ha='right', fontsize=font_size)
    plt.yticks(rotation=0, fontsize=font_size)
    plt.tight_layout()
    
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close()
    
    print(f"Confusion matrix saved to: {output_path}")


def plot_per_class_metrics(metrics: Dict, output_path: Path) -> None:
    """Plot per-class performance metrics."""
    df = pd.DataFrame(metrics['per_class_metrics'])
    
    # Sort by F1 score
    df = df.sort_values('f1', ascending=True)
    
    # Plot
    fig, axes = plt.subplots(1, 3, figsize=(18, max(8, len(df) * 0.3)))
    
    for idx, metric in enumerate(['precision', 'recall', 'f1']):
        ax = axes[idx]
        bars = ax.barh(df['class'], df[metric], color=plt.cm.viridis(df[metric]))
        ax.set_xlabel(metric.capitalize(), fontsize=12)
        ax.set_title(f'Per-Class {metric.capitalize()}', fontsize=14)
        ax.set_xlim(0, 1)
        ax.grid(axis='x', alpha=0.3)
        
        # Add value labels
        for i, (val, cls) in enumerate(zip(df[metric], df['class'])):
            ax.text(val + 0.01, i, f'{val:.2f}', va='center', fontsize=8)
    
    plt.tight_layout()
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close()
    
    print(f"Per-class metrics plot saved to: {output_path}")


def analyze_confidence_distribution(probabilities: np.ndarray, predictions: np.ndarray,
                                   labels: np.ndarray, output_path: Path) -> Dict:
    """Analyze prediction confidence distribution."""
    # Get max probabilities (confidence scores)
    max_probs = np.max(probabilities, axis=1)
    correct = (predictions == labels)
    
    # Confidence for correct vs incorrect predictions
    correct_confidence = max_probs[correct]
    incorrect_confidence = max_probs[~correct]
    
    # Plot
    plt.figure(figsize=(12, 5))
    
    plt.subplot(1, 2, 1)
    plt.hist([correct_confidence, incorrect_confidence], bins=50, 
             label=['Correct', 'Incorrect'], alpha=0.7)
    plt.xlabel('Confidence Score')
    plt.ylabel('Frequency')
    plt.title('Confidence Distribution: Correct vs Incorrect Predictions')
    plt.legend()
    plt.grid(alpha=0.3)
    
    plt.subplot(1, 2, 2)
    thresholds = np.arange(0.5, 1.0, 0.05)
    accuracies = []
    coverages = []
    
    for threshold in thresholds:
        mask = max_probs >= threshold
        if mask.sum() > 0:
            acc = correct[mask].mean()
            cov = mask.mean()
        else:
            acc = 0
            cov = 0
        accuracies.append(acc)
        coverages.append(cov)
    
    ax1 = plt.gca()
    ax2 = ax1.twinx()
    
    ax1.plot(thresholds, accuracies, 'b-', marker='o', label='Accuracy')
    ax2.plot(thresholds, coverages, 'r-', marker='s', label='Coverage')
    
    ax1.set_xlabel('Confidence Threshold')
    ax1.set_ylabel('Accuracy', color='b')
    ax2.set_ylabel('Coverage (% of samples)', color='r')
    ax1.set_title('Accuracy vs Coverage at Different Thresholds')
    ax1.grid(alpha=0.3)
    
    lines1, labels1 = ax1.get_legend_handles_labels()
    lines2, labels2 = ax2.get_legend_handles_labels()
    ax1.legend(lines1 + lines2, labels1 + labels2, loc='center left')
    
    plt.tight_layout()
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close()
    
    print(f"Confidence analysis saved to: {output_path}")
    
    return {
        'mean_confidence_correct': float(correct_confidence.mean()),
        'mean_confidence_incorrect': float(incorrect_confidence.mean()),
        'median_confidence_correct': float(np.median(correct_confidence)),
        'median_confidence_incorrect': float(np.median(incorrect_confidence))
    }


def benchmark_inference_time(model: nn.Module, dataloader: DataLoader,
                            device: torch.device, iterations: int = 100) -> Dict:
    """Benchmark model inference speed."""
    model.eval()
    
    times = []
    
    print(f"\nBenchmarking inference time ({iterations} iterations)...")
    
    with torch.no_grad():
        for i, (inputs, _) in enumerate(dataloader):
            if i >= iterations:
                break
            
            inputs = inputs.to(device)
            
            # Warmup for GPU
            if i == 0 and device.type == 'cuda':
                _ = model(inputs)
                torch.cuda.synchronize()
                continue
            
            start = time.time()
            _ = model(inputs)
            
            if device.type == 'cuda':
                torch.cuda.synchronize()
            
            elapsed = (time.time() - start) * 1000  # Convert to ms
            times.append(elapsed)
    
    times = np.array(times)
    batch_size = dataloader.batch_size
    
    return {
        'avg_time_ms': float(times.mean()),
        'std_time_ms': float(times.std()),
        'min_time_ms': float(times.min()),
        'max_time_ms': float(times.max()),
        'median_time_ms': float(np.median(times)),
        'batch_size': batch_size,
        'images_per_second': float(batch_size / (times.mean() / 1000))
    }


def generate_evaluation_report(metrics: Dict, confidence_analysis: Dict,
                               inference_benchmark: Dict, metadata: Dict,
                               output_path: Path) -> None:
    """Generate comprehensive evaluation report in JSON format."""
    report = {
        'evaluation_date': time.strftime('%Y-%m-%d %H:%M:%S'),
        'model_info': metadata,
        'metrics': metrics,
        'confidence_analysis': confidence_analysis,
        'inference_benchmark': inference_benchmark
    }
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2)
    
    print(f"\nEvaluation report saved to: {output_path}")


def print_evaluation_summary(metrics: Dict, confidence_analysis: Dict,
                            inference_benchmark: Dict) -> None:
    """Print evaluation summary to console."""
    print(f"\n{'='*60}")
    print("Evaluation Summary")
    print(f"{'='*60}")
    print(f"\nOverall Metrics:")
    print(f"  Accuracy: {metrics['overall_accuracy']*100:.2f}%")
    print(f"  Top-3 Accuracy: {metrics['top3_accuracy']*100:.2f}%")
    if metrics['top5_accuracy'] is not None:
        print(f"  Top-5 Accuracy: {metrics['top5_accuracy']*100:.2f}%")
    print(f"  Precision (macro): {metrics['precision_macro']:.4f}")
    print(f"  Recall (macro): {metrics['recall_macro']:.4f}")
    print(f"  F1 Score (macro): {metrics['f1_macro']:.4f}")
    
    print(f"\nConfidence Analysis:")
    print(f"  Mean confidence (correct): {confidence_analysis['mean_confidence_correct']:.4f}")
    print(f"  Mean confidence (incorrect): {confidence_analysis['mean_confidence_incorrect']:.4f}")
    
    print(f"\nInference Performance:")
    print(f"  Average time: {inference_benchmark['avg_time_ms']:.1f} ms")
    print(f"  Throughput: {inference_benchmark['images_per_second']:.1f} images/sec")
    
    # Best and worst performing classes
    per_class = sorted(metrics['per_class_metrics'], key=lambda x: x['f1'])
    
    print(f"\nTop 5 Best Performing Classes (by F1):")
    for cls_metrics in per_class[-5:][::-1]:
        print(f"  {cls_metrics['class']}: F1={cls_metrics['f1']:.3f}, "
              f"Acc={cls_metrics['accuracy']:.3f}, Support={cls_metrics['support']}")
    
    print(f"\nTop 5 Worst Performing Classes (by F1):")
    for cls_metrics in per_class[:5]:
        print(f"  {cls_metrics['class']}: F1={cls_metrics['f1']:.3f}, "
              f"Acc={cls_metrics['accuracy']:.3f}, Support={cls_metrics['support']}")
    
    print(f"\n{'='*60}\n")


def main():
    parser = argparse.ArgumentParser(
        description='Evaluate trained crop disease classification model'
    )
    
    parser.add_argument(
        '--model-path',
        type=str,
        required=True,
        help='Path to trained model (.pth file)'
    )
    
    parser.add_argument(
        '--dataset',
        type=str,
        choices=['plantvillage', 'plantdoc', 'merged', 'custom'],
        default='plantvillage',
        help='Dataset to evaluate on'
    )
    
    parser.add_argument(
        '--dataset-path',
        type=str,
        help='Custom dataset path (required if dataset=custom)'
    )
    
    parser.add_argument(
        '--test-split',
        type=str,
        default='test',
        help='Name of test split folder (test, valid, val)'
    )
    
    parser.add_argument(
        '--batch-size',
        type=int,
        default=32,
        help='Evaluation batch size'
    )
    
    parser.add_argument(
        '--device',
        type=str,
        choices=['cpu', 'cuda', 'auto'],
        default='auto',
        help='Device to use for evaluation'
    )
    
    parser.add_argument(
        '--output-dir',
        type=str,
        default=r'f:\khetopedia\backend\evaluation',
        help='Output directory for evaluation results'
    )
    
    parser.add_argument(
        '--confusion-matrix',
        action='store_true',
        default=True,
        help='Generate confusion matrix'
    )
    
    parser.add_argument(
        '--per-class-metrics',
        action='store_true',
        default=True,
        help='Generate per-class metrics visualization'
    )
    
    parser.add_argument(
        '--benchmark-inference',
        action='store_true',
        default=True,
        help='Benchmark inference time'
    )
    
    parser.add_argument(
        '--num-workers',
        type=int,
        default=2,
        help='Number of data loader workers'
    )
    
    args = parser.parse_args()
    
    # Setup device
    if args.device == 'auto':
        device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    else:
        device = torch.device(args.device)
    
    print(f"Using device: {device}")
    
    # Determine dataset path
    if args.dataset == 'custom':
        if not args.dataset_path:
            raise ValueError("--dataset-path required when using custom dataset")
        dataset_path = Path(args.dataset_path)
    elif args.dataset == 'plantvillage':
        dataset_path = Path(r'f:\khetopedia\assets\images\New Plant Diseases Dataset(Augmented)\New Plant Diseases Dataset(Augmented)')
    elif args.dataset == 'plantdoc':
        dataset_path = Path(r'f:\khetopedia\assets\images\PlantDoc-Dataset-master')
    elif args.dataset == 'merged':
        dataset_path = Path(r'f:\khetopedia\backend\data\processed\merged')
    
    # Create output directory
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    
    # Load model
    model_path = Path(args.model_path)
    if not model_path.exists():
        raise ValueError(f"Model file not found: {model_path}")
    
    model, metadata = load_model_and_metadata(model_path, device)
    
    # Load test dataset
    test_dataset, class_names = load_test_dataset(dataset_path, args.test_split)
    
    test_loader = DataLoader(
        test_dataset,
        batch_size=args.batch_size,
        shuffle=False,
        num_workers=args.num_workers,
        pin_memory=True if device.type == 'cuda' else False
    )
    
    # Run evaluation
    results = evaluate_model(model, test_loader, device)
    
    # Compute metrics
    print("\nComputing metrics...")
    metrics = compute_metrics(
        results['predictions'],
        results['labels'],
        results['probabilities'],
        class_names
    )
    
    # Confusion matrix
    if args.confusion_matrix:
        print("\nGenerating confusion matrix...")
        cm = confusion_matrix(results['labels'], results['predictions'])
        cm_path = output_dir / 'confusion_matrix.png'
        plot_confusion_matrix(cm, class_names, cm_path, normalize=True)
    
    # Per-class metrics
    if args.per_class_metrics:
        print("\nGenerating per-class metrics visualization...")
        metrics_path = output_dir / 'per_class_metrics.png'
        plot_per_class_metrics(metrics, metrics_path)
        
        # Save as CSV
        df = pd.DataFrame(metrics['per_class_metrics'])
        csv_path = output_dir / 'per_class_metrics.csv'
        df.to_csv(csv_path, index=False)
        print(f"Per-class metrics CSV saved to: {csv_path}")
    
    # Confidence analysis
    print("\nAnalyzing prediction confidence...")
    confidence_path = output_dir / 'confidence_analysis.png'
    confidence_analysis = analyze_confidence_distribution(
        results['probabilities'],
        results['predictions'],
        results['labels'],
        confidence_path
    )
    
    # Benchmark inference
    inference_benchmark = {}
    if args.benchmark_inference:
        inference_benchmark = benchmark_inference_time(model, test_loader, device)
    
    # Generate report
    report_path = output_dir / 'evaluation_report.json'
    generate_evaluation_report(metrics, confidence_analysis, inference_benchmark,
                              metadata, report_path)
    
    # Print summary
    print_evaluation_summary(metrics, confidence_analysis, inference_benchmark)
    
    print(f"All evaluation results saved to: {output_dir}")
    
    return 0


if __name__ == '__main__':
    sys.exit(main())

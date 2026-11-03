"""
Dataset Preprocessing Script for Khetopedia ML Pipeline
Handles PlantVillage and PlantDoc datasets with Windows path support
"""
import argparse
import json
import sys
from pathlib import Path
from typing import Dict, List, Tuple
import shutil

# Add parent directory to path for imports
sys.path.append(str(Path(__file__).parent.parent))


def load_class_mapping(mapping_file: Path) -> Dict[str, str]:
    """Load PlantDoc to PlantVillage class name mapping."""
    if not mapping_file.exists():
        print(f"Warning: Mapping file not found at {mapping_file}")
        return {}
    
    with open(mapping_file, 'r', encoding='utf-8') as f:
        data = json.load(f)
    return data.get('mappings', {})


def analyze_dataset_structure(dataset_path: Path, dataset_name: str) -> Dict:
    """
    Analyze dataset directory structure and generate statistics.
    
    Args:
        dataset_path: Path to dataset root (containing train/ and valid/ or test/)
        dataset_name: Name of dataset (plantvillage or plantdoc)
    
    Returns:
        Dictionary with dataset statistics
    """
    stats = {
        'dataset': dataset_name,
        'path': str(dataset_path),
        'splits': {},
        'total_classes': 0,
        'total_images': 0
    }
    
    # Check for train/valid/test splits
    for split_name in ['train', 'valid', 'test']:
        split_path = dataset_path / split_name
        if not split_path.exists():
            continue
        
        split_stats = {
            'classes': [],
            'class_counts': {},
            'total_images': 0
        }
        
        # Iterate through class folders
        for class_folder in sorted(split_path.iterdir()):
            if not class_folder.is_dir():
                continue
            
            class_name = class_folder.name
            # Count images (jpg, jpeg, png)
            image_files = list(class_folder.glob('*.jpg')) + \
                         list(class_folder.glob('*.jpeg')) + \
                         list(class_folder.glob('*.png')) + \
                         list(class_folder.glob('*.JPG'))
            
            image_count = len(image_files)
            
            split_stats['classes'].append(class_name)
            split_stats['class_counts'][class_name] = image_count
            split_stats['total_images'] += image_count
        
        stats['splits'][split_name] = split_stats
        stats['total_images'] += split_stats['total_images']
    
    # Count unique classes across all splits
    all_classes = set()
    for split_data in stats['splits'].values():
        all_classes.update(split_data['classes'])
    stats['total_classes'] = len(all_classes)
    
    return stats


def normalize_plantdoc_names(dataset_path: Path, mapping: Dict[str, str], dry_run: bool = False) -> None:
    """
    Normalize PlantDoc class folder names to PlantVillage standard.
    
    Args:
        dataset_path: Path to PlantDoc dataset root
        mapping: Dict mapping PlantDoc names to PlantVillage names
        dry_run: If True, only print what would be done
    """
    print("\nNormalizing PlantDoc class names...")
    
    for split_name in ['train', 'test']:
        split_path = dataset_path / split_name
        if not split_path.exists():
            continue
        
        print(f"\nProcessing {split_name} split...")
        
        for class_folder in split_path.iterdir():
            if not class_folder.is_dir():
                continue
            
            old_name = class_folder.name
            new_name = mapping.get(old_name)
            
            if new_name and new_name != old_name:
                new_path = split_path / new_name
                
                if dry_run:
                    print(f"  Would rename: '{old_name}' -> '{new_name}'")
                else:
                    if new_path.exists():
                        print(f"  Warning: Target folder already exists: {new_name}")
                    else:
                        class_folder.rename(new_path)
                        print(f"  Renamed: '{old_name}' -> '{new_name}'")
            else:
                print(f"  No mapping for: '{old_name}'")


def create_merged_dataset(plantvillage_path: Path, plantdoc_path: Path, 
                         output_path: Path, mapping: Dict[str, str]) -> None:
    """
    Create merged dataset combining PlantVillage and PlantDoc.
    
    Args:
        plantvillage_path: Path to PlantVillage dataset
        plantdoc_path: Path to PlantDoc dataset
        output_path: Path for merged dataset output
        mapping: PlantDoc to PlantVillage name mapping
    """
    print("\nCreating merged dataset...")
    
    # Create output directory structure
    train_out = output_path / 'train'
    valid_out = output_path / 'valid'
    test_out = output_path / 'test'
    
    train_out.mkdir(parents=True, exist_ok=True)
    valid_out.mkdir(parents=True, exist_ok=True)
    test_out.mkdir(parents=True, exist_ok=True)
    
    # Copy PlantVillage train and valid
    print("\nCopying PlantVillage dataset...")
    pv_train = plantvillage_path / 'train'
    pv_valid = plantvillage_path / 'valid'
    
    if pv_train.exists():
        for class_folder in pv_train.iterdir():
            if class_folder.is_dir():
                dest = train_out / class_folder.name
                if not dest.exists():
                    shutil.copytree(class_folder, dest)
                    print(f"  Copied {class_folder.name} ({len(list(class_folder.glob('*.jpg')))} images)")
    
    if pv_valid.exists():
        for class_folder in pv_valid.iterdir():
            if class_folder.is_dir():
                dest = valid_out / class_folder.name
                if not dest.exists():
                    shutil.copytree(class_folder, dest)
    
    # Add PlantDoc images to corresponding classes
    print("\nAdding PlantDoc dataset...")
    pd_train = plantdoc_path / 'train'
    pd_test = plantdoc_path / 'test'
    
    for pd_split, output_split in [(pd_train, train_out), (pd_test, test_out)]:
        if not pd_split.exists():
            continue
        
        for class_folder in pd_split.iterdir():
            if not class_folder.is_dir():
                continue
            
            pd_class_name = class_folder.name
            pv_class_name = mapping.get(pd_class_name, pd_class_name)
            
            dest = output_split / pv_class_name
            dest.mkdir(exist_ok=True)
            
            # Copy images with prefix to avoid name collisions
            images = list(class_folder.glob('*.jpg')) + list(class_folder.glob('*.png'))
            for img in images:
                dest_img = dest / f"plantdoc_{img.name}"
                if not dest_img.exists():
                    shutil.copy2(img, dest_img)
            
            print(f"  Added {len(images)} PlantDoc images to {pv_class_name}")
    
    print(f"\nMerged dataset created at: {output_path}")


def generate_statistics_report(stats: Dict, output_file: Path) -> None:
    """
    Generate and save dataset statistics report.
    
    Args:
        stats: Dataset statistics dictionary
        output_file: Path to save JSON report
    """
    output_file.parent.mkdir(parents=True, exist_ok=True)
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(stats, f, indent=2)
    
    print(f"\nStatistics saved to: {output_file}")
    
    # Print summary
    print(f"\n{'='*60}")
    print(f"Dataset: {stats['dataset']}")
    print(f"Total Classes: {stats['total_classes']}")
    print(f"Total Images: {stats['total_images']}")
    print(f"{'='*60}")
    
    for split_name, split_data in stats['splits'].items():
        print(f"\n{split_name.upper()} Split:")
        print(f"  Classes: {len(split_data['classes'])}")
        print(f"  Total Images: {split_data['total_images']}")
        print(f"  Avg Images/Class: {split_data['total_images'] / len(split_data['classes']):.1f}")
        
        # Show class distribution (top 5 and bottom 5)
        sorted_classes = sorted(split_data['class_counts'].items(), 
                               key=lambda x: x[1], reverse=True)
        print(f"\n  Top 5 classes by image count:")
        for class_name, count in sorted_classes[:5]:
            print(f"    {class_name}: {count}")
        
        if len(sorted_classes) > 10:
            print(f"\n  Bottom 5 classes by image count:")
            for class_name, count in sorted_classes[-5:]:
                print(f"    {class_name}: {count}")


def main():
    parser = argparse.ArgumentParser(
        description='Preprocess PlantVillage and PlantDoc datasets for ML training'
    )
    
    parser.add_argument(
        '--dataset',
        type=str,
        choices=['plantvillage', 'plantdoc', 'merged', 'all'],
        default='all',
        help='Dataset to preprocess'
    )
    
    parser.add_argument(
        '--plantvillage-path',
        type=str,
        default=r'f:\khetopedia\assets\images\New Plant Diseases Dataset(Augmented)\New Plant Diseases Dataset(Augmented)',
        help='Path to PlantVillage dataset'
    )
    
    parser.add_argument(
        '--plantdoc-path',
        type=str,
        default=r'f:\khetopedia\assets\images\PlantDoc-Dataset-master',
        help='Path to PlantDoc dataset'
    )
    
    parser.add_argument(
        '--mapping-file',
        type=str,
        default=r'f:\khetopedia\backend\models\class_mappings\plantdoc_to_plantvillage.json',
        help='Path to PlantDoc->PlantVillage mapping file'
    )
    
    parser.add_argument(
        '--output',
        type=str,
        default=r'f:\khetopedia\backend\data\processed',
        help='Output directory for processed datasets'
    )
    
    parser.add_argument(
        '--stats',
        action='store_true',
        help='Generate and display dataset statistics'
    )
    
    parser.add_argument(
        '--normalize',
        action='store_true',
        help='Normalize PlantDoc class names (WARNING: modifies original dataset)'
    )
    
    parser.add_argument(
        '--merge',
        action='store_true',
        help='Create merged dataset combining PlantVillage and PlantDoc'
    )
    
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Show what would be done without making changes'
    )
    
    args = parser.parse_args()
    
    # Convert paths to Path objects
    pv_path = Path(args.plantvillage_path)
    pd_path = Path(args.plantdoc_path)
    mapping_file = Path(args.mapping_file)
    output_path = Path(args.output)
    
    # Validate dataset paths
    if args.dataset in ['plantvillage', 'merged', 'all'] and not pv_path.exists():
        print(f"Error: PlantVillage dataset not found at {pv_path}")
        return 1
    
    if args.dataset in ['plantdoc', 'merged', 'all'] and not pd_path.exists():
        print(f"Error: PlantDoc dataset not found at {pd_path}")
        return 1
    
    # Load mapping
    mapping = load_class_mapping(mapping_file)
    
    # Process PlantVillage
    if args.dataset in ['plantvillage', 'all']:
        print(f"\n{'='*60}")
        print("Processing PlantVillage Dataset")
        print(f"{'='*60}")
        
        if args.stats:
            pv_stats = analyze_dataset_structure(pv_path, 'PlantVillage')
            stats_file = output_path / 'plantvillage_stats.json'
            generate_statistics_report(pv_stats, stats_file)
    
    # Process PlantDoc
    if args.dataset in ['plantdoc', 'all']:
        print(f"\n{'='*60}")
        print("Processing PlantDoc Dataset")
        print(f"{'='*60}")
        
        if args.normalize:
            if args.dry_run:
                print("\n[DRY RUN MODE - No changes will be made]")
            normalize_plantdoc_names(pd_path, mapping, dry_run=args.dry_run)
        
        if args.stats:
            pd_stats = analyze_dataset_structure(pd_path, 'PlantDoc')
            stats_file = output_path / 'plantdoc_stats.json'
            generate_statistics_report(pd_stats, stats_file)
    
    # Create merged dataset
    if args.merge or args.dataset == 'merged':
        print(f"\n{'='*60}")
        print("Creating Merged Dataset")
        print(f"{'='*60}")
        
        if args.dry_run:
            print("\n[DRY RUN MODE - Merged dataset will not be created]")
        else:
            merged_path = output_path / 'merged'
            create_merged_dataset(pv_path, pd_path, merged_path, mapping)
            
            if args.stats:
                merged_stats = analyze_dataset_structure(merged_path, 'Merged')
                stats_file = output_path / 'merged_stats.json'
                generate_statistics_report(merged_stats, stats_file)
    
    print(f"\n{'='*60}")
    print("Preprocessing complete!")
    print(f"{'='*60}\n")
    
    return 0


if __name__ == '__main__':
    sys.exit(main())

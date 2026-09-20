"""
Farmer-Herder Conflict Data Filter Module

This module provides functionality to filter UCDP conflict data for Nigeria
to extract farmer-herder conflicts in the Middle Belt region.
"""

import argparse
import csv
import json
import os
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple


@dataclass
class ConflictRecord:
    """Represents a filtered farmer-herder conflict record."""
    
    id: str
    relid: str
    year: int
    conflict_name: str
    dyad_name: str
    side_a: str
    side_b: str
    adm_1: str
    adm_2: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    date_start: Optional[str] = None
    date_end: Optional[str] = None
    deaths_a: int = 0
    deaths_b: int = 0
    deaths_civilians: int = 0
    deaths_unknown: int = 0
    best: int = 0
    high: int = 0
    low: int = 0
    source_article: Optional[str] = None
    source_headline: Optional[str] = None
    where_description: Optional[str] = None
    where_coordinates: Optional[str] = None
    geom_wkt: Optional[str] = None
    
    def to_dict(self) -> Dict:
        """Convert record to dictionary, handling None values."""
        return {
            "id": self.id,
            "relid": self.relid,
            "year": self.year,
            "conflict_name": self.conflict_name,
            "dyad_name": self.dyad_name,
            "side_a": self.side_a,
            "side_b": self.side_b,
            "adm_1": self.adm_1,
            "adm_2": self.adm_2,
            "latitude": self.latitude,
            "longitude": self.longitude,
            "date_start": self.date_start,
            "date_end": self.date_end,
            "deaths": {
                "side_a": self.deaths_a,
                "side_b": self.deaths_b,
                "civilians": self.deaths_civilians,
                "unknown": self.deaths_unknown,
                "best_estimate": self.best,
                "high_estimate": self.high,
                "low_estimate": self.low,
                "total": self.deaths_a + self.deaths_b + self.deaths_civilians + self.deaths_unknown
            },
            "location": {
                "description": self.where_description,
                "coordinates": self.where_coordinates,
                "geom_wkt": self.geom_wkt
            },
            "sources": {
                "article": self.source_article,
                "headline": self.source_headline
            }
        }


# Keywords for filtering
HERDER_KEYWORDS: Set[str] = {
    "herder", "herders", "fulani", "militia", "pastoralist", "pastoralists",
    "cattle", "grazing", "nomad", "nomadic"
}

FARMER_KEYWORDS: Set[str] = {
    "farmer", "farmers", "tiv", "berom", "eggon", "hausa", "agatu",
    "idoma", "jukun", "mambila", "tarok", "afizere", "kofyar",
    "agatu", "alago", "etulo", "kwah", "mada", "akwanga"
}

MIDDLE_BELT_STATES: Set[str] = {
    "benue", "plateau", "kaduna", "nasarawa", "taraba"
}


def contains_keyword(text: str, keywords: Set[str]) -> bool:
    """
    Check if text contains any of the keywords (case-insensitive).
    
    Args:
        text: The text to search in
        keywords: Set of keywords to look for
        
    Returns:
        True if any keyword is found, False otherwise
    """
    if not text:
        return False
    text_lower = text.lower()
    return any(keyword in text_lower for keyword in keywords)


def is_herder_group(name: str) -> bool:
    """Check if a group name indicates herders."""
    return contains_keyword(name, HERDER_KEYWORDS)


def is_farmer_group(name: str) -> bool:
    """Check if a group name indicates farmers."""
    return contains_keyword(name, FARMER_KEYWORDS)


def is_middle_belt_state(state: str) -> bool:
    """Check if a state is in the Middle Belt region."""
    if not state:
        return False
    state_lower = state.lower()
    return any(mb_state in state_lower for mb_state in MIDDLE_BELT_STATES)


def is_farmer_herder_conflict(
    type_of_violence: str,
    side_a: str,
    side_b: str,
    adm_1: str
) -> bool:
    """
    Determine if a conflict record represents a farmer-herder conflict.
    
    Criteria:
    1. type_of_violence == 2 (Non-State Conflict)
    2. One side is a herder group (Fulani, herders, militia)
    3. The other side is a farmer group (Tiv, Berom, Eggon, etc.)
    4. Conflict occurs in Middle Belt states (Benue, Plateau, Kaduna, Nasarawa, Taraba)
    
    Args:
        type_of_violence: The type of violence code
        side_a: First party in the conflict
        side_b: Second party in the conflict
        adm_1: Administrative level 1 (state)
        
    Returns:
        True if this is a farmer-herder conflict, False otherwise
    """
    # Check type of violence (2 = Non-State Conflict)
    try:
        violence_type = int(float(type_of_violence)) if type_of_violence else 0
        if violence_type != 2:
            return False
    except (ValueError, TypeError):
        return False
    
    # Check if in Middle Belt
    if not is_middle_belt_state(adm_1):
        return False
    
    # Check if one side is herder and the other is farmer
    herder_a = is_herder_group(side_a)
    herder_b = is_herder_group(side_b)
    farmer_a = is_farmer_group(side_a)
    farmer_b = is_farmer_group(side_b)
    
    # Case 1: Herder vs Farmer
    if (herder_a and farmer_b) or (herder_b and farmer_a):
        return True
    
    # Case 2: Both sides have herder and farmer keywords (e.g., "Fulani - Tiv")
    if (herder_a or herder_b) and (farmer_a or farmer_b):
        return True
    
    return False


def parse_numeric(value: str, default: int = 0) -> int:
    """Safely parse a numeric value from string."""
    try:
        return int(float(value)) if value and value.strip() else default
    except (ValueError, TypeError):
        return default


def parse_float(value: str) -> Optional[float]:
    """Safely parse a float value from string."""
    try:
        return float(value) if value and value.strip() else None
    except (ValueError, TypeError):
        return None


def parse_date(value: str) -> Optional[str]:
    """Parse and format date string."""
    if not value or value.strip() == "":
        return None
    try:
        # Handle datetime strings
        if " " in value:
            dt = datetime.strptime(value.split(".")[0], "%Y-%m-%d %H:%M:%S")
            return dt.strftime("%Y-%m-%d")
        # Handle date-only strings
        dt = datetime.strptime(value.split(".")[0], "%Y-%m-%d")
        return dt.strftime("%Y-%m-%d")
    except (ValueError, TypeError):
        return value.strip()


def read_conflict_data(file_path: str) -> List[ConflictRecord]:
    """
    Read and filter conflict data from CSV file.
    
    Args:
        file_path: Path to the CSV file
        
    Returns:
        List of filtered ConflictRecord objects
        
    Raises:
        FileNotFoundError: If the file doesn't exist
        Exception: For other file reading errors
    """
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"CSV file not found: {file_path}")
    
    records: List[ConflictRecord] = []
    
    try:
        with open(file_path, mode='r', encoding='utf-8') as csvfile:
            # Read CSV with proper handling of quoted fields
            reader = csv.DictReader(csvfile)
            
            for row_num, row in enumerate(reader, start=2):  # start=2 because row 1 is header
                try:
                    # Check if this is a farmer-herder conflict
                    if not is_farmer_herder_conflict(
                        row.get('type_of_violence', ''),
                        row.get('side_a', ''),
                        row.get('side_b', ''),
                        row.get('adm_1', '')
                    ):
                        continue
                    
                    # Parse the record
                    record = ConflictRecord(
                        id=row.get('id', ''),
                        relid=row.get('relid', ''),
                        year=parse_numeric(row.get('year', '0')),
                        conflict_name=row.get('conflict_name', ''),
                        dyad_name=row.get('dyad_name', ''),
                        side_a=row.get('side_a', ''),
                        side_b=row.get('side_b', ''),
                        adm_1=row.get('adm_1', ''),
                        adm_2=row.get('adm_2', ''),
                        latitude=parse_float(row.get('latitude', '')),
                        longitude=parse_float(row.get('longitude', '')),
                        date_start=parse_date(row.get('date_start', '')),
                        date_end=parse_date(row.get('date_end', '')),
                        deaths_a=parse_numeric(row.get('deaths_a', '0')),
                        deaths_b=parse_numeric(row.get('deaths_b', '0')),
                        deaths_civilians=parse_numeric(row.get('deaths_civilians', '0')),
                        deaths_unknown=parse_numeric(row.get('deaths_unknown', '0')),
                        best=parse_numeric(row.get('best', '0')),
                        high=parse_numeric(row.get('high', '0')),
                        low=parse_numeric(row.get('low', '0')),
                        source_article=row.get('source_article', None),
                        source_headline=row.get('source_headline', None),
                        where_description=row.get('where_description', None),
                        where_coordinates=row.get('where_coordinates', None),
                        geom_wkt=row.get('geom_wkt', None)
                    )
                    records.append(record)
                    
                except Exception as e:
                    # Log error but continue processing
                    print(f"Warning: Error parsing row {row_num}: {e}")
                    continue
                    
    except csv.Error as e:
        raise Exception(f"CSV parsing error: {e}")
    except Exception as e:
        raise Exception(f"Error reading file: {e}")
    
    return records


def save_to_json(records: List[ConflictRecord], output_path: str) -> None:
    """
    Save filtered records to JSON file.
    
    Args:
        records: List of ConflictRecord objects
        output_path: Path to save the JSON file
        
    Raises:
        Exception: If there's an error writing the file
    """
    try:
        # Sort records by date_start then by year
        sorted_records = sorted(
            records,
            key=lambda r: (r.date_start or '', r.year)
        )
        
        data = {
            "metadata": {
                "description": "Farmer-Herder Conflicts in Nigeria's Middle Belt Region",
                "source": "UCDP Conflict Data",
                "filter_criteria": {
                    "type_of_violence": 2,
                    "herder_keywords": sorted(HERDER_KEYWORDS),
                    "farmer_keywords": sorted(FARMER_KEYWORDS),
                    "states": sorted(MIDDLE_BELT_STATES)
                },
                "total_records": len(records),
                "date_generated": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            },
            "data": [record.to_dict() for record in sorted_records]
        }
        
        with open(output_path, 'w', encoding='utf-8') as jsonfile:
            json.dump(data, jsonfile, indent=2, ensure_ascii=False)
            
    except Exception as e:
        raise Exception(f"Error saving JSON file: {e}")


def save_to_csv(records: List[ConflictRecord], output_path: str) -> None:
    """
    Save filtered records to CSV file.
    
    Args:
        records: List of ConflictRecord objects
        output_path: Path to save the CSV file
        
    Raises:
        Exception: If there's an error writing the file
    """
    try:
        # Sort records by date_start then by year
        sorted_records = sorted(
            records,
            key=lambda r: (r.date_start or '', r.year)
        )
        
        if not sorted_records:
            # Write empty CSV with headers if no data
            with open(output_path, 'w', encoding='utf-8') as csvfile:
                writer = csv.writer(csvfile)
                writer.writerow([
                    'id', 'relid', 'year', 'conflict_name', 'dyad_name',
                    'side_a', 'side_b', 'state', 'lga', 'latitude', 'longitude',
                    'date_start', 'date_end', 'deaths_a', 'deaths_b',
                    'deaths_civilians', 'deaths_unknown', 'best_estimate',
                    'high_estimate', 'low_estimate', 'source_article',
                    'source_headline', 'location_description'
                ])
            return
        
        # Define CSV fieldnames
        fieldnames = [
            'id', 'relid', 'year', 'conflict_name', 'dyad_name',
            'side_a', 'side_b', 'state', 'lga', 'latitude', 'longitude',
            'date_start', 'date_end', 'deaths_a', 'deaths_b',
            'deaths_civilians', 'deaths_unknown', 'best_estimate',
            'high_estimate', 'low_estimate', 'source_article',
            'source_headline', 'location_description'
        ]
        
        with open(output_path, 'w', encoding='utf-8', newline='') as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writeheader()
            
            for record in sorted_records:
                writer.writerow({
                    'id': record.id,
                    'relid': record.relid,
                    'year': record.year,
                    'conflict_name': record.conflict_name,
                    'dyad_name': record.dyad_name,
                    'side_a': record.side_a,
                    'side_b': record.side_b,
                    'state': record.adm_1,
                    'lga': record.adm_2,
                    'latitude': record.latitude,
                    'longitude': record.longitude,
                    'date_start': record.date_start,
                    'date_end': record.date_end,
                    'deaths_a': record.deaths_a,
                    'deaths_b': record.deaths_b,
                    'deaths_civilians': record.deaths_civilians,
                    'deaths_unknown': record.deaths_unknown,
                    'best_estimate': record.best,
                    'high_estimate': record.high,
                    'low_estimate': record.low,
                    'source_article': record.source_article or '',
                    'source_headline': record.source_headline or '',
                    'location_description': record.where_description or ''
                })
                
    except Exception as e:
        raise Exception(f"Error saving CSV file: {e}")


def filter_farmer_herder_conflicts(
    input_csv_path: str,
    output_json_path: str = "/output/farmer_herder_conflict.json",
    output_csv_path: str = "/output/farmer_herder_conflict.csv"
) -> Tuple[int, str, str]:
    """
    Main function to filter farmer-herder conflicts from UCDP Nigeria conflict data.
    
    This function reads the input CSV file, applies filtering criteria to identify
    farmer-herder conflicts in Nigeria's Middle Belt region, and saves the results
    in both JSON (for client applications) and CSV (for HuggingFace publishing) formats.
    
    Filtering Criteria:
    1. type_of_violence == 2 (Non-State Conflict: armed conflict between two groups,
       neither of which is the state)
    2. Actor names contain herder-related keywords (Fulani, herders, militia, etc.)
    3. Actor names contain farmer-related keywords (Tiv, Berom, Eggon, etc.)
    4. Conflict occurs in Middle Belt states (Benue, Plateau, Kaduna, Nasarawa, Taraba)
    
    Args:
        input_csv_path: Path to the input conflict_data_nga.csv file
        output_json_path: Path to save the JSON output (default: /output/farmer_herder_conflict.json)
        output_csv_path: Path to save the CSV output (default: /output/farmer_herder_conflict.csv)
        
    Returns:
        Tuple containing:
        - Number of filtered records
        - Path to the JSON file
        - Path to the CSV file
        
    Raises:
        FileNotFoundError: If input file doesn't exist
        Exception: For any processing or output errors
        
    Example:
        >>> count, json_path, csv_path = filter_farmer_herder_conflicts(
        ...     "conflict_data_nga.csv",
        ...     "farmer_herder_conflict.json",
        ...     "farmer_herder_conflict.csv"
        ... )
        >>> print(f"Filtered {count} records")
    """
    # Validate input
    if not input_csv_path:
        raise ValueError("Input CSV path cannot be empty")
    
    if not os.path.exists(input_csv_path):
        raise FileNotFoundError(f"Input file not found: {input_csv_path}")
    
    print(f"Reading conflict data from: {input_csv_path}")
    
    # Read and filter data
    try:
        records = read_conflict_data(input_csv_path)
        print(f"Found {len(records)} farmer-herder conflict records")
        
        if not records:
            print("Warning: No farmer-herder conflicts found matching the criteria")
        
    except Exception as e:
        raise Exception(f"Error reading and filtering data: {e}")
    
    # Save outputs
    try:
        # Save JSON
        json_path = Path(output_json_path).absolute()
        save_to_json(records, str(json_path))
        print(f"Saved JSON to: {json_path}")
        
        # Save CSV
        csv_path = Path(output_csv_path).absolute()
        save_to_csv(records, str(csv_path))
        print(f"Saved CSV to: {csv_path}")
        
        return len(records), str(json_path), str(csv_path)
        
    except Exception as e:
        raise Exception(f"Error saving output files: {e}")


def main() -> None:
    """
    Command-line entry point for the farmer-herder conflict filter.
    
    Usage:
        python filter_farmer_herder.py [input_csv] [output_json] [output_csv]
        
    Args:
        input_csv: Path to input CSV (default: conflict_data_nga.csv)
        output_json: Path to output JSON (default: farmer_herder_conflict.json)
        output_csv: Path to output CSV (default: farmer_herder_conflict.csv)
    """
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Filter UCDP Nigeria conflict data for farmer-herder conflicts"
    )
    parser.add_argument(
        "--input",
        type=str,
        default="source/conflict_data_nga.csv",
        help="Path to input CSV file (default: source/conflict_data_nga.csv)"
    )
    parser.add_argument(
        "--json-output",
        type=str,
        default="output/farmer_herder_conflict.json",
        help="Path to output JSON file (default: output/farmer_herder_conflict.json)"
    )
    parser.add_argument(
        "--csv-output",
        type=str,
        default="output/farmer_herder_conflict.csv",
        help="Path to output CSV file (default: output/farmer_herder_conflict.csv)"
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Show verbose output"
    )
    
    args = parser.parse_args()
    
    try:
        # Run the filtering
        count, json_path, csv_path = filter_farmer_herder_conflicts(
            args.input, args.json_output, args.csv_output
        )
        
        if args.verbose:
            print(f"\n✓ Successfully filtered {count} farmer-herder conflict records")
            print(f"✓ JSON output: {json_path}")
            print(f"✓ CSV output: {csv_path}")
        else:
            print(f"Filtered {count} records -> JSON: {json_path}, CSV: {csv_path}")
            
    except Exception as e:
        print(f"Error: {e}")
        exit(1)


if __name__ == "__main__":
    main()

# Farmer-Herder Conflict Data Filter

This project filters UCDP (Uppsala Conflict Data Program) Nigeria conflict data to extract farmer-herder conflicts in the Middle Belt region.

## Overview

The script reads `conflict_data_nga.csv` and applies the following filtering criteria:

1. **Conflict Type**: `type_of_violence == 2` (Non-State Conflict - armed conflict between two groups, neither of which is the state)
2. **Actor Names**: Checks `side_a` and `side_b` columns for:
   - Herder/Militia keywords: Fulani, herders, militia, pastoralist, cattle, grazing, nomad
   - Farmer keywords: Tiv, Berom, Eggon, Hausa, Agatu, Idoma, Jukun, Mambila, Tarok, etc.
3. **State**: Filters for Middle Belt states: Benue, Plateau, Kaduna, Nasarawa, Taraba

## Output Files

The script generates two output files:

1. **`farmer_herder_conflict.json`** - Structured JSON format ideal for client applications
   - Contains metadata with filtering criteria
   - Organized data structure with nested fields (deaths, location, sources)
   - Easy to parse and use in web/mobile applications

2. **`farmer_herder_conflict.csv`** - Tabular CSV format for publishing on HuggingFace
   - Flattened structure suitable for dataset hosting
   - Clean column names for easy analysis

## Quick Start

### Using `uv` (Recommended)

```bash
# Install uv if not already installed
curl -LsSf https://astral.sh/uv/install.sh | sh

# Run the filter
uv run python filter_farmer_herder.py
```

### Using Python Directly

```bash
# Run with defaults
python filter_farmer_herder.py

# Or with custom paths
python filter_farmer_herder.py --input my_conflicts.csv --json-output output.json --csv-output output.csv

# Verbose output
python filter_farmer_herder.py --verbose
```

### Using pip install (Development)

```bash
# Create virtual environment
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install in development mode
pip install -e .

# Run via entry point
filter-conflicts
```

## Usage as a Module

```python
from filter_farmer_herder import filter_farmer_herder_conflicts

# Filter with default output paths
count, json_path, csv_path = filter_farmer_herder_conflicts("conflict_data_nga.csv")

# Filter with custom output paths
count, json_path, csv_path = filter_farmer_herder_conflicts(
    input_csv_path="conflict_data_nga.csv",
    output_json_path="my_farmer_herder.json",
    output_csv_path="my_farmer_herder.csv"
)

print(f"Filtered {count} records")
print(f"JSON: {json_path}")
print(f"CSV: {csv_path}")
```

## Data Structure

### JSON Output Format

```json
{
  "metadata": {
    "description": "Farmer-Herder Conflicts in Nigeria's Middle Belt Region",
    "source": "UCDP Conflict Data",
    "filter_criteria": {
      "type_of_violence": 2,
      "herder_keywords": [...],
      "farmer_keywords": [...],
      "states": [...]
    },
    "total_records": 555,
    "date_generated": "2026-09-20 16:09:15"
  },
  "data": [
    {
      "id": "17125",
      "relid": "NIG-2001-2-X637-1",
      "year": 2001,
      "conflict_name": "Fulani, Jukun - Tiv",
      "dyad_name": "Fulani, Jukun - Tiv",
      "side_a": "Fulani, Jukun",
      "side_b": "Tiv",
      "adm_1": "Taraba state",
      "adm_2": "",
      "latitude": 8.0,
      "longitude": 10.5,
      "date_start": "2001-07-01",
      "date_end": "2001-07-01",
      "deaths": {
        "side_a": 0,
        "side_b": 0,
        "civilians": 0,
        "unknown": 20,
        "best_estimate": 20,
        "high_estimate": 29,
        "low_estimate": 20,
        "total": 20
      },
      "location": {
        "description": "Taraba state",
        "coordinates": "Taraba state",
        "geom_wkt": "POINT (10.5 8)"
      },
      "sources": {
        "article": "...",
        "headline": "..."
      }
    }
  ]
}
```

### CSV Output Format

| Column | Description |
|--------|-------------|
| id | Unique identifier |
| relid | Relation ID |
| year | Year of conflict |
| conflict_name | Conflict name |
| dyad_name | Dyad name |
| side_a | First party |
| side_b | Second party |
| state | State (adm_1) |
| lga | Local Government Area (adm_2) |
| latitude | Latitude coordinate |
| longitude | Longitude coordinate |
| date_start | Start date (YYYY-MM-DD) |
| date_end | End date (YYYY-MM-DD) |
| deaths_a | Deaths on side A |
| deaths_b | Deaths on side B |
| deaths_civilians | Civilian deaths |
| deaths_unknown | Unknown deaths |
| best_estimate | Best death estimate |
| high_estimate | High death estimate |
| low_estimate | Low death estimate |
| source_article | Source article text |
| source_headline | Source headline |
| location_description | Location description |

## Filter Criteria Details

### Herder Keywords
- herder, herders
- fulani
- militia
- pastoralist, pastoralists
- cattle
- grazing
- nomad, nomadic

### Farmer Keywords
- farmer, farmers
- tiv
- berom
- eggon
- hausa
- agatu
- idoma
- jukun
- mambila
- tarok
- afizere
- kofyar
- kwah
- mada
- akwanga
- alago
- etulo

### Middle Belt States
- Benue
- Plateau
- Kaduna
- Nasarawa
- Taraba (included as it's adjacent and has significant conflicts)

## Error Handling

The script includes comprehensive error handling:
- File not found validation
- CSV parsing error handling
- Type conversion safety (numeric, float, date parsing)
- Row-level error handling (continues processing on row errors)
- Clean exception messages

## Type Safety

The code uses Python type hints throughout:
- `TypedDict` and `dataclass` for structured data
- `Optional` types for nullable fields
- `Set` for keyword collections
- `List` and `Dict` for collections
- `Tuple` for return types

## Project Structure

```
├── source/conflict_data_nga.csv          # Input data
├── filter_farmer_herder.py        # Main filtering script
├── output/farmer_herder_conflict.json    # JSON output (generated)
├── output/farmer_herder_conflict.csv     # CSV output (generated)
├── pyproject.toml                 # Project configuration
└── README.md                      # This file
```

## License

This project is open source and available for use in research and applications related to conflict analysis in Nigeria.

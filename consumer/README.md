# Kafka consumer (Python)

This is the Kafka adapter for Python: it allows you to easily connect Python services to Apache Kafka via Python.

## Installation

You need to install [Python 3+](https://www.python.org/).

To run the examples you will need to install the dependencies specified in the file `requirements.txt`.
For that, run:

On Linux:

```bash
python -m venv .venv
source .venv\Scripts\activate
pip3 install -r requirements.txt
```

On Windows:

```cmd
python -m venv .venv
.\.venv\Scripts\activate.bat
pip3 install -r requirements.txt
```

## Usage

You can run the test consumer using:

```bash
python main.py
```

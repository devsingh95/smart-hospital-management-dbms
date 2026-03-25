import os
import sys

# Ensure project root is importable in Vercel serverless runtime.
PROJECT_ROOT = os.path.dirname(os.path.dirname(__file__))
if PROJECT_ROOT not in sys.path:
    sys.path.insert(0, PROJECT_ROOT)

from app import app

# Vercel expects a top-level WSGI app variable.

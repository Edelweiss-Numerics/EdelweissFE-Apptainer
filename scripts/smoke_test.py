# Smoke test of a built image, run inside it as
#   env PYTHON_GIL=0 python - < scripts/smoke_test.py
# by scripts/deploy.sh (on the cluster) and CI: the Marmot-backed and linear
# solver extensions load, and no import re-enables the GIL.
import sys

import edelweissfe.elements.marmotelement.element  # noqa: F401
import edelweissfe.linsolve.amgcl.amgcl  # noqa: F401
import edelweissfe.linsolve.pardiso.pardiso  # noqa: F401
import edelweissfe.materials.marmot.marmotgradientenhancedhypoelastic  # noqa: F401
import edelweissfe.materials.marmot.marmothypoelastic  # noqa: F401

assert not sys._is_gil_enabled(), "GIL re-enabled by an import"
print("smoke test OK")

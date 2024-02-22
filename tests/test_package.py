import pytest
import heavyai


@pytest.mark.xfail
def test_versioning():
    assert heavyai.__version__ not in (None, "", "0.0.0")

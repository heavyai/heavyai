import heavyai


def test_versioning():
    assert heavyai.__version__ not in (None, "", "0.0.0")

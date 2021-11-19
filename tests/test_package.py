import pyomnisci


def test_versioning():
    assert pyomnisci.__version__ not in (None, "", "0.0.0")

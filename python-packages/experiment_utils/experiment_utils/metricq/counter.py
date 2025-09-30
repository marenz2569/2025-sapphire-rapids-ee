
class Counter(dict):
    """
    A dict that has the element 0 for each missing entry.
    """
    def __missing__(self, key):
        return 0

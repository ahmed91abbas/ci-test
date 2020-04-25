import os
import sys
sys.path.append(os.path.abspath('src'))

import main

def test_main():
    actual = main.sum(1, 1)

    assert actual == 2

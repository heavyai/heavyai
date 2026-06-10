# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

import heavyai


def test_versioning():
    assert heavyai.__version__ not in (None, "", "0.0.0")

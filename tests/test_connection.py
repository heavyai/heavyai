# SPDX-FileCopyrightText: Copyright (c) 2026, NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

from unittest.mock import Mock

import pandas as pd

from heavyai.connection import Connection


def test_create_table_calls_current_thrift_signature():
    con = Connection.__new__(Connection)
    con.sessionid = "session"
    con._session = "session"
    con._client = Mock()
    data = pd.DataFrame({"x": pd.Series([1], dtype="int64")})

    con.create_table("table_name", data)

    args, kwargs = con._client.create_table.call_args
    assert kwargs == {}
    assert args[0] == "session"
    assert args[1] == "table_name"
    assert len(args) == 3

import datetime
import numpy as np
import pandas as pd

from types import MethodType
from ._mutators import set_tdf, get_tdf
from .ipc import load_buffer, shmdt


def seconds_to_time(seconds):
    """Convert seconds since midnight to a datetime.time"""
    m, s = divmod(seconds, 60)
    h, m = divmod(m, 60)
    return datetime.time(h, m, s)


def time_to_seconds(time):
    """Convert a datetime.time to seconds since midnight"""
    if time is None:
        return None
    return 3600 * time.hour + 60 * time.minute + time.second


def datetime_to_seconds(arr):
    """Convert an array of datetime64[ns] to seconds since the UNIX epoch"""

    if arr.dtype != np.dtype('datetime64[ns]'):
        if arr.dtype == 'int64':
            # The user has passed a unix timestamp already
            return arr

        if not (
            arr.dtype == 'object'
            or str(arr.dtype).startswith('datetime64[ns,')
        ):
            raise TypeError(
                f"Invalid dtype '{arr.dtype}', expected one of: "
                "datetime64[ns], int64 (UNIX epoch), "
                "or object (string)"
            )

        # Convert to datetime64[ns] from string
        # Or from datetime with timezone information
        # Return timestamp in 'UTC'
        arr = pd.to_datetime(arr, utc=True)
        return arr.view('i8') // 10 ** 9  # ns -> s since epoch
    else:
        if arr.dt.nanosecond.sum():
            return arr.view('i8')  # ns -> s since epoch
        else:
            return arr.view('i8') // 10 ** 9


def datetime_in_precisions(epoch, precision):
    """Convert epoch time value into s, ms, us, ns"""
    base = datetime.datetime(1970, 1, 1)
    if precision == 0:
        return base + datetime.timedelta(seconds=epoch)
    elif precision == 3:
        seconds, modulus = divmod(epoch, 1000)
        return base + datetime.timedelta(seconds=seconds, milliseconds=modulus)
    elif precision == 6:
        seconds, modulus = divmod(epoch, 1000000)
        return base + datetime.timedelta(seconds=seconds, microseconds=modulus)
    elif precision == 9:
        return np.datetime64(epoch, 'ns')
    else:
        raise TypeError("Invalid timestamp precision: {}".format(precision))


def date_to_seconds(arr):
    """Converts date into seconds"""

    return arr.apply(lambda x: np.datetime64(x, "s").astype(int))

def _parse_tdf_gpu(tdf):
    """
    Parse the results of a select ipc_gpu into a GpuDataFrame

    Parameters
    ----------
    tdf : TDataFrame

    Returns
    -------
    gdf : GpuDataFrame
    """

    import pyarrow as pa
    from cudf.comm.gpuarrow import GpuArrowReader
    from cudf.core.dataframe import DataFrame
    from pyarrow._cuda import Context, IpcMemHandle
    from numba import cuda

    ipc_handle = IpcMemHandle.from_buffer(pa.py_buffer(tdf.df_handle))
    ctx = Context()
    ipc_buf = ctx.open_ipc_buffer(ipc_handle)
    ipc_buf.context.synchronize()

    schema_buffer, shm_ptr = load_buffer(tdf.sm_handle, tdf.sm_size)

    buffer = pa.BufferReader(schema_buffer)
    schema = pa.ipc.read_schema(buffer)

    # Dictionary Memo functionality used to
    # deserialize on the C++ side is not
    # exposed on the pyarrow side, so we need to
    # handle this on our own.
    dict_memo = {}

    try:
        dict_batch_reader = pa.RecordBatchStreamReader(buffer)
        updated_fields = []

        for f in schema:
            if pa.types.is_dictionary(f.type):
                msg = dict_batch_reader.read_next_batch()
                dict_memo[f.name] = msg.column(0)
                updated_fields.append(pa.field(f.name, f.type.index_type))
            else:
                updated_fields.append(pa.field(f.name, f.type))

        schema = pa.schema(updated_fields)
    except pa.ArrowInvalid:
        # This message does not have any dictionary encoded
        # columns
        pass

    dtype = np.dtype(np.byte)
    darr = cuda.devicearray.DeviceNDArray(
        shape=ipc_buf.size,
        strides=dtype.itemsize,
        dtype=dtype,
        gpu_data=ipc_buf.to_numba(),
    )

    reader = GpuArrowReader(schema, darr)
    df = DataFrame()
    df.set_tdf = MethodType(set_tdf, df)
    df.get_tdf = MethodType(get_tdf, df)

    for k, v in reader.to_dict().items():
        if k in dict_memo:
            df[k] = pa.DictionaryArray.from_arrays(v.to_arrow(), dict_memo[k])
        else:
            df[k] = v

    df.set_tdf(tdf)

    # free shared memory from Python
    # https://github.com/omnisci/pymapd/issues/46
    # https://github.com/omnisci/pymapd/issues/31
    free_sm = shmdt(ctypes.cast(shm_ptr, ctypes.c_void_p))  # noqa

    return df


mapd_to_slot = {
    'BOOL': 'int_col',
    'BOOLEAN': 'int_col',
    'SMALLINT': 'int_col',
    'INT': 'int_col',
    'INTEGER': 'int_col',
    'BIGINT': 'int_col',
    'FLOAT': 'real_col',
    'DECIMAL': 'int_col',
    'DOUBLE': 'real_col',
    'TIMESTAMP': 'int_col',
    'DATE': 'int_col',
    'TIME': 'int_col',
    'STR': 'str_col',
    'POINT': 'str_col',
    'LINESTRING': 'str_col',
    'POLYGON': 'str_col',
    'MULTIPOLYGON': 'str_col',
    'TINYINT': 'int_col',
    'GEOMETRY': 'str_col',
    'GEOGRAPHY': 'str_col',
}


mapd_to_na = {
    'BOOL': -128,
    'BOOLEAN': -128,
    'SMALLINT': -32768,
    'INT': -2147483648,
    'INTEGER': -2147483648,
    'BIGINT': -9223372036854775808,
    'FLOAT': 0,
    'DECIMAL': 0,
    'DOUBLE': 0,
    'TIMESTAMP': -9223372036854775808,
    'DATE': -9223372036854775808,
    'TIME': -9223372036854775808,
    'STR': '',
    'POINT': '',
    'LINESTRING': '',
    'POLYGON': '',
    'MULTIPOLYGON': '',
    'TINYINT': -128,
    'GEOMETRY': '',
    'GEOGRAPHY': '',
}

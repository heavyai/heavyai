import json
from base64 import b64decode, b64encode


def _change_dashboard_sources(dashboard, remap):
    """
    Remap a dashboard to use a new table
    Parameters
    ----------
    dashboard: A dictionary containing the old dashboard state
    remap: A dictionary containing the new dashboard state to be mapped
    Returns
    -------
    dashboard: A base64 encoded json object containing the new dashboard state
    """
    dm = json.loads(dashboard.dashboard_metadata)
    tlst = map(str.strip, dm.get('table', '').split(','))
    tlst = [
        remap[t]['name'] if remap.get(t, {}).get('name', {}) else t
        for t in tlst
    ]
    dm['table'] = ', '.join(tlst)

    # Load our dashboard state into a python dictionary
    ds = json.loads(b64decode(dashboard.dashboard_state).decode())

    # If it's a 5.4 tabbed dashboard, iterate through the tabs
    # otherwise convert the dashboard state as-is
    if ds.get('tabs', None):
        for tabname, tabdef in ds.get('tabs').items():
            ds['tabs'][tabname] = _table_remap(tabdef, remap)
    else:
        ds = _table_remap(ds, remap)

    # Convert our new dashboard state to a python object
    dashboard.dashboard_state = b64encode(json.dumps(ds).encode()).decode()
    dashboard.dashboard_metadata = json.dumps(dm)
    return dashboard


def _table_remap(tab, remap):
    # Remap items in our old dashboard state to the new table name
    for old_table, defs in remap.items():
        new_table = defs.get('name', {}) or old_table
        if tab['dashboard']['table'] == old_table:
            tab['dashboard']['table'] = new_table

        # Change the name of the dashboard or use the old one
        tab['dashboard']['title'] = (
            defs.get('title', {}) or tab['dashboard']['title']
        )

        # Remap our datasources keys
        for key, val in tab['dashboard']['dataSources'].items():
            for col in val['columnMetadata']:
                if col['table'] == old_table:
                    col['table'] = new_table

        # Remap our charts to the new table
        for c, val in tab['charts'].items():
            if val.get('dataSource', None):
                if tab['charts'][c]['dataSource'] == old_table:
                    tab['charts'][c]['dataSource'] = new_table

            # Remap Our Dimensions to the new table
            i = 0
            for dim in val.get('dimensions', []):
                if dim.get('table', {}) == old_table:
                    tab['charts'][c]['dimensions'][i]['table'] = new_table
                if dim.get('selector', {}).get('table') == old_table:
                    (
                        tab['charts'][c]['dimensions'][i]['selector']['table']
                    ) = new_table
                i += 1

            # Remap Our Measures to the new table
            i = 0
            for m in val.get('measures', []):
                if m.get('table', None) == old_table:
                    tab['charts'][c]['measures'][i]['table'] = new_table
                i += 1

            # Remap Our Layers to the new table
            il = 0
            for layer in val.get('layers', []):
                im = 0
                if layer.get('dataSource', {}) == old_table:
                    tab['charts'][c]['layers'][il]['dataSource'] = new_table
                for measure in layer.get('measures', []):
                    if measure.get('table', None) == old_table:
                        (
                            tab['charts'][c]['layers'][il]['measures'][im][
                                'table'
                            ]
                        ) = new_table
                    im += 1
                il += 1
        if tab['dashboard']['dataSources'].get(old_table, None):
            (tab['dashboard']['dataSources'][new_table]) = tab['dashboard'][
                'dataSources'
            ].pop(old_table)
        return tab

root = global ? window

class root.CsvReader
  valid_values = (row) ->
    delete row[""]
    row

  constructor: (csv_data) ->
    @headers = _($.csv2Array(csv_data)[0]).filter (colname) -> colname != ""
    @rows    = (valid_values(row) for row in $.csv2Dictionary(csv_data))

  is_valid_csv_file: ->
    true

  to_json: ->
    """
    {
      \"column_names\" : #{$.toJSON(@headers)},
      \"row_data\" : #{$.toJSON(@rows)}
    }
    """

if exports?
  exports.CsvReader = root.CsvReader


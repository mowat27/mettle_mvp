root = global ? window

class root.CsvReader
  constructor: (csv_data) ->
    @headers     = $.csv2Array(csv_data)[0]
    @rows        = $.csv2Dictionary(csv_data)

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


root = global ? window

class root.CsvReader
  constructor: (csv_data) ->
    @raw_csv     = csv_data
    @csv_array   = $.csv2Array(csv_data)

  is_valid_csv_file: ->
    for row in @csv_array
      return false if row.length == 0
    true

  to_json: ->
    """
    {
      \"column_names\" : #{$.toJSON(@csv_array[0])},
      \"row_data\" : #{$.toJSON($.csv2Dictionary(@raw_csv))}
    }
    """
  row_data: ->
    result = "["
    for row in @rows
      result += row.to_json_array(@header_row)
      result += ","
    result.replace(/,$/, '') + "]"

if exports?
  exports.CsvReader = root.CsvReader


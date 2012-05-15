root = global ? window

class root.CsvReader
  constructor: (csv_data) ->
    @raw_csv     = csv_data
    @new_array   = $.csv2Array(csv_data)
    @csv_data    = csv_data.split("\n")
    @header_row  = new HeaderRow(@new_array[0])
    @rows        = (new Row(raw_row) for raw_row in @csv_data[1..-1])

  is_valid_csv_file: ->
    for row in @rows
      return false if row.is_empty()
    true

  to_json: ->
    """
    {
      \"column_names\" : #{@header_row.to_json_array()},
      \"row_data\" : #{@row_data()}
    }
    """
  row_data: ->
    result = "["
    for row in @rows
      result += row.to_json_array(@header_row)
      result += ","
    result.replace(/,$/, '') + "]"

class HeaderRow
  constructor: (column_names) ->
    @column_names = column_names

  json_array = (values) ->
    $.toJSON(values)

  to_json_array: ->
    json_array(@column_names)

  each_indexed_column_name: (func) ->
    index = 0
    for column_name in @column_names
      func.apply(this, [column_name, index])
      index += 1


class Row
  constructor: (values) ->
    @values = values.split(",")

  is_empty: ->
    @values.length == 1

  to_json_array: (header_row) ->
    result = "{"
    values = @values
    header_row.each_indexed_column_name (column_name, column_index) ->
      value = values[column_index] ? '""'
      result += "#{$.toJSON(column_name)} : #{value},"
    result.replace(/,$/, '') + "}"

if exports?
  exports.CsvReader = root.CsvReader


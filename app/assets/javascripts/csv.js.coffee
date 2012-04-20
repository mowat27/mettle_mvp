root = global ? window

class root.CsvReader
  constructor: (csv_data) ->
    @csv_data    = csv_data.split("\n")
    @header_row  = new HeaderRow(@csv_data[0].split(","))
    @rows        = (new Row(raw_row) for raw_row in @csv_data[1..-1])

  to_json: ->
    row_data = @row_data()
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
    result = "["
    for value in values
      result += "#{value},"
    result.replace(/,$/, '') + "]"

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

  to_json_array: (header_row) ->
    result = "{"
    values = @values
    header_row.each_indexed_column_name (column_name, column_index) ->
      value = values[column_index] ? '""'
      result += "#{column_name} : #{value},"
    result.replace(/,$/, '') + "}"

if exports?
  exports.CsvReader = root.CsvReader


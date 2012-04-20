root = global ? window

failed_columns = (row) ->
  result = []
  for column, response of row
    result.push(column) if response.expected != response.actual
  result

run_tests = (source) ->
  result =
    column_names: source.column_names
    results: []
  for row in source.results
    meta = {}
    meta.failed_columns = failed_columns(row)
    meta.num_columns = source.results.length
    meta.num_failures = meta.failed_columns.length
    if meta.num_failures > 0
      meta.test_result = "failed"
    else
      meta.test_result = "passed"
    row.meta = meta
    result.results.push row
  result

write_attr = (attr,val) -> "#{attr}='#{val}'"

tag = (tag_name, value, attributes = {}) ->
  attrs = (write_attr(attr, val) for attr, val of attributes).join(" ")
  "<#{tag_name} #{attrs}>#{value}</#{tag_name}>"

tr = (values, cell_tag, css_class) ->
  result = "<tr>"
  for value in values
    result += tag(cell_tag, value, {class: css_class})
  result + "</tr>"

nvl = (value, alternative) ->
  if value && value != ""
    return value
  alternative

format = (r) ->
  expected = nvl(r.expected, "nil")
  actual = nvl(r.actual, "nil")
  if expected == actual
    {css_class: "passed", text: actual}
  else
    {css_class: "failed", text: "Expected: #{expected}<br/>Got: #{actual}"}

write_table = (data, columns) ->
  columns_to_display = columns ? (colname for colname in data.column_names when colname != "meta")
  result = "<table>"
  result += tr(columns_to_display, "th", "header")
  for row in data.results
    formatted_rows = (format(test_result) for colname, test_result of row when (columns_to_display.indexOf(colname) > -1))
    result += "<tr>"
    for f_row in formatted_rows
      {css_class, text} = f_row
      result += tag("td", text, {class: css_class})
    result += "</tr>"
  result + "</table>"

filter = (list, func) -> item for item in list when func(item)
filter_source = (src, func) ->
  rows_to_display = filter src.results, func
  failures =
    column_names: src.column_names,
    results: rows_to_display

sum = (nums) ->
  result = 0
  for n in nums
    result += n
  result

all_failed_columns = (rows) ->
  result = []
  for row in rows
    for col in row.meta.failed_columns
      result.push(col) unless result.indexOf(col) > -1
  result

class ResultsTable
  constructor: (name, staged_data) ->
    @stats =
      total_rows:     staged_data.results.length
      passed_rows:    (row for row in staged_data.results when row.meta.test_result == "passed").length
      failed_rows:    (row for row in staged_data.results when row.meta.test_result == "failed").length
      failed_columns: all_failed_columns staged_data.results
    @staged_data = staged_data
    @div_id = "#{name}-results-table"
    @skeleton_html = """
<div id="#{@div_id}">
  <div class="summary">
    Summary:
    <a class="show-all-link total" href='#all'>All</a>,
    <a class="show-passed-link passed" href='#passed'>Passed</a>,
    <a class="show-failed-link failed" href='#failed'>Failed</a>
  </div>
  <a class="failed-columns-only" href="#">Show failed columns only</a>
  <div class="results">
    <div class="all"></div>
    <div class="passed"></div>
    <div class="failed"></div>
  </div>
</div>
"""
    @dom = $(@skeleton_html)

  find: (query) ->
    @dom.find(query)

  failure_rate: ->
    result = ((@stats.failed_rows / @stats.total_rows) * 100).toPrecision 2
    if result == "NaN"
      0
    else
      result

  all_results_table: ->
    write_table(@staged_data)

  to_jquery: ->
    self = @
    @dom = $(@skeleton_html)

    @find(".show-all-link").text "#{@stats.total_rows} rows tested"
    @find(".show-failed-link").text "#{@stats.failed_rows} rows failed (#{@failure_rate()}%)"
    @find(".show-passed-link").text "#{@stats.passed_rows} rows passed"

    @find(".failed-columns-only").hide()

    div_id = @div_id
    @find(".show-all-link").click ->
      self.find(".failed-columns-only").hide()
      self.find(".results").empty().append("<h2>All Rows</h2>").append("<p>Loading results...</p>")
      self.find(".results").empty().append("<h2>All Rows</h2>").append(self.all_results_table())

    @find(".show-failed-link").click ->
      self.find(".failed-columns-only").show()
      data = filter_source self.staged_data, (row) -> row.meta.test_result == "failed"
      self.find(".results").empty().
      append("<h2>All Failures</h2>").
      append(write_table(data))

    @find(".show-passed-link").click ->
      self.find(".failed-columns-only").hide()
      data = filter_source self.staged_data, (row) -> row.meta.test_result == "passed"
      self.find(".results").empty().
      append("<h2>Passes</h2>").
      append(write_table(data))

    @find(".failed-columns-only").click ->
      data = filter_source self.staged_data, (row) -> row.meta.test_result == "failed"
      self.find(".results").empty().append("<h2>Failed Columns</h2>").
      append(write_table(data, self.stats.failed_columns))

    @find(".show-failed-link").click() if @stats.total_rows > 0
    @dom

root.run_tests = run_tests
root.ResultsTable = ResultsTable

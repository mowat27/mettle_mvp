root = global ? window

$ ->
  if !file_api_supported()
    alert "Sorry - the File API is not supported so this page doesn't work"
  else
    run_page()
    $("#compare-button").click()

file_api_supported = ->
  window.File && window.FileReader && window.FileList && window.Blob

comparison = new root.Comparison(["freebase_id"])

run_page = ->
  $("#expected_csv_input").change (evt) ->
    comparison.load_results("expected", evt.target.files)

  $("#actual_csv_input").change (evt) ->
    comparison.load_results("actual", evt.target.files)

  $("#compare-button").click ->
    comparison.compare()
    results = root.run_tests(JSON.parse(comparison.to_json()))
    test_table = new root.ResultsTable("test", results)
    $("#results_table_test").empty().append(test_table.to_jquery())

# --------------------------------------------------------------------
# Demo Stuff

# handle_file_select = (evt) ->
#   file_list = evt.target.files
#   list_all_files(file_list)
#   show_thumbs(file_list)

# list_all_files = (files) ->
#   $("#list").empty().append("<ul>")
#   for f in files
#     $("#list").append( $("<li>#{fs_details(f)}</li>") )

# show_thumbs = (files) ->
#   for f in files
#     continue unless f.type.match('image.*')
#     reader = new FileReader
#     reader.onload = (evt) ->
#       thumb = render_thumbnail(evt,f)
#       $("#list").append(thumb)

#     reader.onerror = (evt) ->
#       alert("error: #{evt}")


#     reader.readAsDataURL(f)

# render_thumbnail = (evt,f) ->
#   span = $("<span>").append($("<img class='thumb' src='#{evt.target.result}' title='#{escape(f.fileName)}'>"))


# fs_details = (f) ->
#   "<strong>#{escape(f.name)}</strong> type: #{f.type || 'n/a'}, size: #{f.size} bytes, last modified: #{f.lastModifiedDate}"

#
# --------------------------------------------------------------------

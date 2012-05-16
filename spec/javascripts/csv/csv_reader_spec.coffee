root = global ? window

describe "CsvReader#is_valid_csv_file", ->
  beforeEach ->
    @data = '''
"a","b","c"
"1","2","3"
    '''

  it "is true", ->
    csv_reader = new root.CsvReader(@data)
    expect(csv_reader.is_valid_csv_file()).toBeTruthy()

  # it "is false when blank lines in CSV data", ->
  #   csv_reader = new root.CsvReader(@data + "\n")
  #   expect(csv_reader.is_valid_csv_file()).toBeFalsy()

describe "CsvReader#to_json", ->
  beforeEach ->
    @data = '''
"a","b","c"
"1","2","3"
'''

  it "converts to json", ->
    expected = '''
{
  "column_names" : ["a","b","c"],
  "row_data" : [{"a":"1","b":"2","c":"3"}]
}
'''
    csv_reader = new root.CsvReader(@data)
    expect(csv_reader.to_json()).toEqual(expected)

  it "ignores columns with empty headers", ->
    @data = '''
"a",,"c"
"1","2","3"
"4","5","6"
'''

    expected = '''
{
  "column_names" : ["a","c"],
  "row_data" : [{"a":"1","c":"3"},{"a":"4","c":"6"}]
}
'''
    csv_reader = new root.CsvReader(@data)
    expect(csv_reader.to_json()).toEqual(expected)

  it "treats blanks cell values as empty strings", ->
    @data = '''
"a",b,"c"
"1",,"3"
"4","","6"
'''

    expected = '''
{
  "column_names" : ["a","b","c"],
  "row_data" : [{"a":"1","b":"","c":"3"},{"a":"4","b":"","c":"6"}]
}
'''
    csv_reader = new root.CsvReader(@data)
    expect(csv_reader.to_json()).toEqual(expected)

  it "ignores extra data columns with no header", ->
    @data = '''
"a",b,"c"
"1",2,"3",4,
"4","5","6",5,6
'''

    expected = '''
{
  "column_names" : ["a","b","c"],
  "row_data" : [{"a":"1","b":"2","c":"3"},{"a":"4","b":"5","c":"6"}]
}
'''
    csv_reader = new root.CsvReader(@data)
    expect(csv_reader.to_json()).toEqual(expected)


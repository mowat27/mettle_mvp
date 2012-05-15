root = global ? window

describe "CsvReader#is_valid_csv_file", ->
  beforeEach ->
    @data = '''
"a","b","c"
"1","2","3"
    '''

  it "is true with valid data", ->
    csv_reader = new root.CsvReader(@data)
    expect(csv_reader.is_valid_csv_file()).toBeTruthy()

  it "is false when blank lines in CSV data", ->
    csv_reader = new root.CsvReader(@data + "\n")
    expect(csv_reader.is_valid_csv_file()).toBeFalsy()

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
  "row_data" : [{"a" : "1","b" : "2","c" : "3"}]
}
'''
    csv_reader = new root.CsvReader(@data)
    expect(csv_reader.to_json()).toEqual(expected)

source_dir = "../../app/assets/javascripts"

Diff = require("#{source_dir}/diff.js")
Row = Diff.Row
DataSet = Diff.DataSet
Index = Diff.Index

_ = require("#{source_dir}/underscore.js")._

describe "Diff", ->
  beforeEach ->
    @empty_data_set = new DataSet []

    to_string = (obj) ->
      if obj? && obj.toString?
          obj.toString()
      else
          "#{obj}"

    @addMatchers
      toEquals: (expected)->
        errors = []
        @message = ->
          result = "Objects should be equal using #equals: \n"
          result += "expected: #{to_string(expected)}\n"
          result += "  actual: #{to_string(@actual)}\n\n"
          result += "Errors: "
          result += "#{error}\n" for error in errors
          result
        errors.push("#equals not defined on actual") unless @actual.equals?
        errors.push("data doesn't match") unless @actual.equals(expected)
        errors.length == 0

      toIsEqual: (expected)->
        errors = []
        @message = ->
          result = "Objects should be equal using #equals: \n"
          result += "expected: #{to_string(expected)}\n"
          result += "  actual: #{to_string(@actual)}\n\n"
          result += "Errors: "
          result += "#{error}\n" for error in errors
          result
        errors.push("data doesn't match") unless _.isEqual(@actual, expected)
        errors.length == 0

      toNotEquals: (expected)->
        errors = []
        @message = ->
          result = "Objects should not be equal using #equals: \n"
          result += "expected: #{to_string(expected)}\n"
          result += "  actual: #{to_string(@actual)}\n\n"
          result += "Errors: "
          result += "#{error}\n" for error in errors
          result
        errors.push("#equals not defined on actual") unless @actual.equals?
        errors.push("objects are the same") if @actual.equals(expected)
        errors.length == 0

      toNotIsEqual: (expected)->
        errors = []
        @message = ->
          result = "Objects should not be equal using #equals: \n"
          result += "expected: #{to_string(expected)}\n"
          result += "  actual: #{to_string(@actual)}\n\n"
          result += "Errors: "
          result += "#{error}\n" for error in errors
          result
        errors.push("objects are the same") if _.isEqual(@actual, expected)
        errors.length == 0

      toBehaveLikeARow: ->
        @message = ->
          "#{@actual} is not a row"
        return false unless @actual? && @actual.values?
        true

      toHaveValues: (expected_values) ->
        @message = ->
          actual_values = @actual.values ? "undefined"
          "expected row with values [#{expected_values}] got [#{actual_values}]"
        expected = new Row(expected_values)
        @actual.equals(expected)

      toBeARowWithValues: (expected_values) ->
        expect(@actual).toBeDefined()
        expect(expected_values).toBeDefined()
        expect(@actual).toBehaveLikeARow()
        expect(@actual).toHaveValues(expected_values)
        true

      toHaveRowsWithValues: (values) ->
        expect(@actual.rows).toBeDefined()
        expect(@actual.rows.length).toEqual(values.length)
        expect(@actual.rows[i]).toBeARowWithValues(values[i]) for i, value of values
        true

  describe "intersection", ->
    beforeEach ->
      @column_names = ["col1","col2","col3"]
      @data = [
        ["a","b","c"]
        ["a","d","c"]
        ["a","b","e"]
      ]
      data_set_all = new DataSet(@data)
      data_set_ac = new DataSet(@data[0..1])
      @index = new Index(["col1","col3"], @column_names, data_set_all)
      @other = new Index(["col1","col3"], @column_names, data_set_all)
      @other2 = new Index(["col1","col3"], @column_names, data_set_ac)

      @keygroup_ac = new DataSet([@data[0], @data[1]])
      @keygroup_ae = new DataSet([@data[2]])


    describe "with 2 identical indexes", ->
      it "finds a perfect intersection", ->
        matches = []
        Diff.intersection @index, @other,
          on_match: (key, lhs, rhs) ->
            matches.push [key, lhs, rhs]

        expect(matches).toIsEqual([
          [ new Row(["a","e"]), @keygroup_ae, @keygroup_ae ],
          [ new Row(["a","c"]), @keygroup_ac, @keygroup_ac ],
        ])

      it "does nothing when on_match() is not provided", ->
        matches = []
        Diff.intersection @index, @other
        expect(matches).toIsEqual([])

    describe "when extra rows on the lhs", ->
      it "calls on_unmatched_lhs() for unmatched lhs rows", ->
        rejects = []
        Diff.intersection @index, @other2,
          on_unmatched_lhs: (key, rows) ->
            rejects = [key, rows]
        expect(rejects).toIsEqual([new Row(["a","e"]), @keygroup_ae])

      it "does nothing when on_unmatched_lhs() is not defined", ->
        rejects = []
        Diff.intersection @index, @other2, ->
          on_match: ->
            null

    describe "when extra rows on the rhs", ->
      it "calls on_unmatched_rhs() for unmatched rhs rows", ->
        rejects = []
        Diff.intersection @other2, @index,
          on_unmatched_rhs: (key, rows) ->
            rejects = [key, rows]
        expect(rejects).toIsEqual([new Row(["a","e"]), @keygroup_ae])

      it "does nothing when on_unmatched_rhs() is not defined", ->
        rejects = []
        Diff.intersection @other2, @index, ->
          on_match: ->
            null

  describe "Diff.cartesian", ->
    beforeEach ->
      @numbers = [[1],[2]]
      @numbers_ds = new DataSet(@numbers)
      @letters = [["a"],["b"]]
      @letters_ds = new DataSet(@letters)

    it "calculates and empty array for 2 empty data sets", ->
      result = Diff.cartesian(@empty_data_set, @empty_data_set)
      expect(result).toIsEqual([])

    it "calculates a match for 2 single-row data sets", ->
      result = Diff.cartesian(new DataSet([[1]]), new DataSet([["a"]]))
      expected = [
        [new Row([1]), new Row(["a"])]
      ]
      expect(result).toIsEqual(expected)

    it "calculates the product of 2 multi-row data sets", ->
      result = Diff.cartesian(@numbers_ds, @letters_ds)
      expected = [
        [new Row([1]), new Row(["a"])],
        [new Row([1]), new Row(["b"])],
        [new Row([2]), new Row(["a"])],
        [new Row([2]), new Row(["b"])]
      ]
      expect(result).toIsEqual(expected)

  describe "Diff.Comparison", ->
    beforeEach ->
      @column_names = ["col1","col2","col3"]
      @values = [
        ["a","b","c"]
        ["a","b","e"]
      ]
      @data_set = new DataSet(@values)

      @row1 =
        col1: {expected: "a", actual: "a"}
        col2: {expected: "b", actual: "b"}
        col3: {expected: "e", actual: "e"}
      @row2 =
        col1: {expected: "a", actual: "a"}
        col2: {expected: "b", actual: "b"}
        col3: {expected: "c", actual: "c"}


    describe "with identical data sets", ->
      beforeEach ->
        @comparison = new Comparison(["col1","col3"])
        @comparison.expected.column_names = @column_names
        @comparison.expected.data_set = @data_set

        @comparison.actual.column_names = @column_names
        @comparison.actual.data_set = @data_set

        @comparison.compare()

      it "merges 2 data sets into a single JSON document", ->
        expected =
          column_names: ["col1","col2","col3"],
          results: [@row1, @row2]

        expected = JSON.stringify(expected)

        expect(@comparison.to_json()).toEqual(expected)

    describe "with differently ordered data sets", ->
      beforeEach ->
        other = new root.DataSet(@values.reverse())

        @comparison = new Comparison(@column_names)
        @comparison.expected.column_names = @column_names
        @comparison.expected.data_set = @data_set

        @comparison.actual.column_names = @column_names
        @comparison.actual.data_set = other

        @comparison.compare()

      it "merges 2 data sets into a single JSON document", ->
        expected =
          column_names: ["col1","col2","col3"],
          results: [@row1, @row2]
        expected = JSON.stringify(expected)

        expect(@comparison.to_json()).toEqual(expected)

    describe "with multiple values for a key", ->
      beforeEach ->
        @values.push ["a","b","c"]
        other = new root.DataSet(@values)

        @comparison = new Comparison(@column_names)
        @comparison.expected.column_names = @column_names
        @comparison.expected.data_set = @data_set

        @comparison.actual.column_names = @column_names
        @comparison.actual.data_set = other

        @comparison.compare()

      it "merges 2 data sets into a single JSON document", ->
        expected =
          column_names: ["col1","col2","col3"],
          results: [@row1, @row2, @row2]
        expected = JSON.stringify(expected)

        expect(@comparison.to_json()).toEqual(expected)


  describe "Diff.DataSet", ->
    beforeEach ->
      @column_names = ["col1","col2","col3"]
      @values = [
        ["a","b","c"]
        ["a","d","c"]
        ["a","b","e"]
      ]
      @data_set = new DataSet(@values)

    describe "creating from JSON", ->
      it "creates a dataset from JSON", ->
        json = """
{
  "column_names" : ["col1","col2","col3"],
  "row_data" : [
    {"col1" : "a", "col2" : "b", "col3" : "c"},
    {"col1" : "a", "col2" : "d", "col3" : "c"},
    {"col1" : "a", "col2" : "b", "col3" : "e"}
  ]
}
"""
        expected = new DataSet @values
        expect(DataSet.create_from_json(json)).toEquals(expected)


    describe "#is_empty", ->
      it "is not empty when it holds no rows", ->
        @data_set = @empty_data_set
        expect(@data_set.is_empty()).toBeTruthy()

      it "is not empty when it holds rows", ->
        expect(@data_set.is_empty()).toBeFalsy()

    describe "#equals", ->
      it "is equal when compared to an identical set", ->
        expect(@data_set).toEquals(new DataSet(@values))
        expect(@data_set).toIsEqual(new DataSet(@values))

      it "is not equal when compared to an empty data set", ->
        expect(@data_set).toNotEquals(@empty_data_set)

      it "is not equal when compared to a smaller data set", ->
        expect(@data_set).toNotEquals(new DataSet(@values[0..1]))

      it "is not equal when compared to a larger data set", ->
        expect(@data_set).toNotEquals(new DataSet(@values.push(["x","x","x"])))

      it "is not equal when the rows do not match", ->
        new_values = [
          ["a","b","c"]
          ["a","d","c"]
          ["a","XXXXX","e"]
        ]
        other = new DataSet(new_values)
        expect(@data_set).toNotEquals(other)

      it "is not equal when compared to an object that has no rows", ->
        expect(@data_set).toNotEquals("foo")

    it "can be built from a 2 dimensional array of values", ->
      expect(@data_set).toHaveRowsWithValues(@values)

    it "can be built from an array of Rows", ->
      rows = (new Row(array) for array in @values)
      @data_set = new DataSet(rows)
      expect(@data_set).toHaveRowsWithValues(@values)

    it "creates a slice through its rows", ->
      result = @data_set.slice(@column_names, ["col1","col3"])
      expected_values = [
        ["a","c"]
        ["a","c"]
        ["a","e"]
      ]
      expect(result).toEquals(new DataSet(expected_values))

    it "filters rows by key value", ->
      result = @data_set.filter(@column_names, ["col1","col2"], new Row(["a","b"]))
      @actual = result
      all_values = [["a","b","c"],["a","b","e"]]
      expect(@actual.rows).toBeDefined()
      expect(@actual.rows.length).toEqual(all_values.length)
      expect(@actual.rows[i]).toHaveValues(these_values) for i, these_values of all_values

  describe "Diff.Index", ->
    beforeEach ->
      @column_names = ["col1","col2","col3"]
      @data = [
        ["a","b","c"]
        ["a","d","c"]
        ["a","b","e"]
      ]
      data_set = new DataSet(@data)
      @index = new Index(["col1","col3"], @column_names, data_set)
      @other = new Index(["col1","col3"], @column_names, data_set)
      @other2 = new Index(["col1","col3"], @column_names, new DataSet(@data[0..1]))

    it "returns the key values", ->
      expect(@index.key_values()).toEquals(new DataSet [["a","e"],["a","c"]])

    describe "#get", ->
      it "returns a data set containing rows matching a key", ->
        first_entry = @index.get(new Row(["a","c"]))
        expect(first_entry).toEquals(new DataSet @data[0..1])
        second_entry = @index.get(new Row(["a","e"]))
        expect(second_entry).toEquals(new DataSet [@data[2]])

      it "returns an empty data set when no match found", ->
        result = @index.get(new Row(["x","x"]))
        expect(result).toEquals(@empty_data_set)

    # it "verifies _.isEqual()", ->
    #   o1 =
    #     foo: "bar"
    #     isEqual: (other) ->
    #       true


    #   expect([1,2]).toEqual([1,2])
    #   expect(_.isEqual([1,2],[1,2])).toBeTruthy()
    #   expect(_.isEqual([1,2],[1,3])).toBeFalsy()
    #   expect([1,2] == [1,3]).toBeFalsy()
    #   expect([1,2]).toNotEqual([1,3])

    #   expect(_.isEqual(@index, @index)).toBeTruthy()
    #   expect(_.isEqual(@index, @other2)).toBeTruthy()
    #   # expect(@index == @other).toBeTruthy()
    #   # expect(_.isEqual(new DataSet(@data), new DataSet(@data))).toBeTruthy()

    #   expect(_.isEqual(o1,99)).toBeTruthy()
    #   # expect(o1 == 99).toBeTruthy()

    describe "#merge", ->
      it "calculates the matches between 2 indexes", ->
        expected =
          key: ["col1","col3"]
          values: new Row ["a","c"]
          rows:
            lhs: new Row ["a","b","c"]
            rhs: new Row ["a","x","c"]

        lhs_index = new Index(["col1","col3"], @column_names, new DataSet([["a","b","c"]]))
        rhs_index = new Index(["col1","col3"], @column_names, new DataSet([["a","x","c"]]))

        result = lhs_index.merge(rhs_index)
        expect(_.isEqual(expected, result)).toBeTruthy()
        expect(result).toEqual(expected)

    describe "#intersection", ->
      it "calculates a data set containing matching keys", ->
        index2 = new Index(["col1","col3"], @column_names, new DataSet([["a","b","c"]]))
        result = @index.intersection(index2)
        expect(result).toEquals(new DataSet [["a","c"]])

  describe "Diff.Row", ->
    beforeEach ->
      @column_names = ["a","b","c","d","e"]
      @row = new Row(["v0","v1","v2","v3","v4"])

    describe "#equals", ->
      it "is true when both rows contain the same values", ->
        other = new Row(["v0","v1","v2","v3","v4"])
        expect(@row).toEquals(other)

      it "is false when the rows contain different values", ->
        other = new Row(["v4","v3","v2","v1","v0"])
        expect(@row).toNotEquals(other)

      it "is false when other is shorter than this row", ->
        other = new Row(["v0","v1","v2"])
        expect(@row).toNotEquals(other)

      it "is false when other is longer than this row", ->
        other = new Row(["v0","v1","v2","v3","v4","v5"])
        expect(@row).toNotEquals(other)

      it "is false when the comparison object is not a Row", ->
        other = ["v0","v1","v2","v3","v4"]
        expect(@row).toNotEquals(other)

    describe "#get", ->
      it "finds the value for a given column", ->
        expect(@row.get(@column_names, "b")).toEqual("v1")

      it "returns 'notfound' when the column does not exist", ->
        expect(@row.get(@column_names, "x")).toEqual("notfound")

    describe "#slice", ->
      it "slices a row by column name", ->
        result = @row.slice @column_names, ["a","c"]
        expect(result).toEquals(new Row ["v0","v2"])
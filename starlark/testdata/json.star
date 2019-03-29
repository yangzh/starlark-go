# Tests of json module.
# option:float

load("assert.star", "assert")
load("json.star", "json")

assert.eq(dir(json), ["decode", "encode", "indent"])

## json.encode

assert.eq(json.encode(None), "null")
assert.eq(json.encode(True), "true")
assert.eq(json.encode(-123), "-123")
assert.eq(json.encode(12345*12345*12345*12345*12345*12345), "3539537889086624823140625")
assert.eq(json.encode(12.345e67), "1.2345e+68")
assert.eq(json.encode("hello"), '"hello"')
assert.eq(json.encode([1, 2, 3]), "[1,2,3]")
assert.eq(json.encode((1, 2, 3)), "[1,2,3]")
assert.eq(json.encode(range(3)), "[0,1,2]") # a built-in iterable
assert.eq(json.encode(dict(x = 1, y = "two")), '{"x":1,"y":"two"}')
assert.eq(json.encode(struct(x = 1, y = "two")), '{"x":1,"y":"two"}')  # a user-defined HasAttrs

# errors
assert.fails(lambda: json.encode(float("NaN")), "cannot encode non-finite float NaN")
assert.fails(lambda: json.encode({1: "two"}), "dict has int key, want string")
assert.fails(lambda: json.encode(len), "cannot encode builtin_function_or_method as JSON")
assert.fails(lambda: json.encode(struct(x=[1, {"x": len}])), # nested failure
             'in field .x: at list index 1: in dict key "x": cannot encode...')

## json.decode

assert.eq(json.decode("null"), None)
assert.eq(json.decode("true"), True)
assert.eq(json.decode("-123"), -123)
assert.eq(json.decode("3539537889086624823140625"), float(3539537889086624823140625))
assert.eq(json.decode('[]'), ())
assert.eq(json.decode('[1]'), (1,))
assert.eq(json.decode('[1,2,3]'), (1, 2, 3))
assert.eq(json.decode('{"one": 1, "two": 2}'), dict(one=1, two=2))

# Exercise JSON string coding by round-tripping a string with every 16-bit code point.
def codec(x):
  return json.decode(json.encode(x))
codepoints = ''.join(['%c' % c for c in range(65536)])
assert.eq(codec(codepoints), codepoints)

## json.indent

s = json.encode(dict(x = 1, y = ["one", "two"]))

assert.eq(json.indent(s), '''{
	"x": 1,
	"y": [
		"one",
		"two"
	]
}''')

assert.eq(json.indent(s, prefix='¶', indent='–––'), '''{
¶–––"x": 1,
¶–––"y": [
¶––––––"one",
¶––––––"two"
¶–––]
¶}''')

assert.fails(lambda: json.indent("!@#$%^& this is not json"), 'invalid character')
---

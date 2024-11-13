import strutils, sequtils, re, unicode

proc tokenize*(text: string): seq[string] =
  # Simple tokenizer: lowercase, split by non-alphanumeric characters
  let lowercase = text.toLowerAscii()
  let regexNonAlphaNum = re("[^a-z0-9]+")
  result = lowercase.split(regexNonAlphaNum).mapIt(it.strip()).filterIt(it.len > 0)


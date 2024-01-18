#hello
def key_by($k): 
  if $k|type!="string" then error("String argument expected") else . end |
  if type=="array" then ( reduce .[] as $item ( {}; .[$item[$k]]=($item|del(.[$k])) ) ) else error("Array input expected") end;

def distinct($key):
  map(.[$key]) | unique;


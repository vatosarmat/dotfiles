
#Add one more [] level to [ log_kind ]
s/^(\[ \w+ \])/\[\1\]/
#Remove date
s/\][^]]+\]/\]/
#Remove file name
#s/[^]]+\.lua:[[:digit:]]+\s*/ /
#Move the first opening bracket to the next line
s/\s*\{/\n{/
#Consider 2 more spaces after opening bracket is a new line indent
s/\{(\s{2,})/\{\n\1/g
#Consider 2 more spaces after comma is a new line indent
s/,(\s{2,})/,\n\1/g
#Move the last closing bracket to the next line. Some others also will be moved...
s/([^[:space:]{])}/\1\n}/g
#Consider 2 more spaces before closing bracket is a new line indent
s/(\s{2,})\}/\n\1}/g

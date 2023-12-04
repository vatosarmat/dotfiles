return {
  sfmt(
    'zz',
    [[
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="utf-8" />
  <title>$1@</title>
</head>

<body>
  $2@
</body>

</html>
]],
    i(1, 'title'),
    i(2, 'body')
  ),
}

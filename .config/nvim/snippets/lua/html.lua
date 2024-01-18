return {
  sfmt(
    'zz',
    [[
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
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

  sfmt('tl', [[<link href="$1@" rel="stylesheet" />]], i(1, 'href')),
}

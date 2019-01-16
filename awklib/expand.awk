
function expand(e,ea,r) {
  
  split(e,ea," ")

  if (length(ea) == 1) {
    r = vars[e]
  } 

  else {
    if (ea[2] !~ /^#/) {ea[2] = vars[ea[2]]}
    switch (ea[1]) {

      case "darker":
        r = darker(ea[2],ea[3])
      break

      case "lighter":
        r = lighter(ea[2],ea[3])
      break

      case "more":
        r = more(ea[2],ea[3])
      break

      case "less":
        r = less(ea[2],ea[3])
      break

      case "mix":
        if (ea[3] !~ /^#/) {ea[3] = vars[ea[3]]}
        r = mix(ea[2],ea[3],ea[4])
      break

    }
  }

  if (colorformat != "default") {
    r = printc(r,colorformat)
  }

  return r
}

function printc(c,f,r) {
  # if not a color just return back
  if (c !~ /^#/) {return c}
  r = f
  # if color not in ac array, add it
  if (ac[c]["HEX"]["R"] !~ /./) {addcolor(c)}

  gsub(/%R/,ac[c]["HEX"]["R"],r)
  gsub(/%G/,ac[c]["HEX"]["G"],r)
  gsub(/%B/,ac[c]["HEX"]["B"],r)
  gsub(/%A/,ac[c]["HEX"]["A"],r)
  gsub(/%r/,ac[c]["RGB"]["R"],r)
  gsub(/%g/,ac[c]["RGB"]["G"],r)
  gsub(/%b/,ac[c]["RGB"]["B"],r)
  gsub(/%a/,ac[c]["RGB"]["A"],r)

  return r
}

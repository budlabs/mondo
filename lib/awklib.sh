#!/usr/bin/env bash

awklib() {
cat << 'EOB'
function addcolor(hex) {

  if (match(hex,/^#([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})([A-Fa-f0-9]{2})?/,ma)) {
    ac[hex]["RGB"]["R"]=strtonum("0x"ma[1])
    ac[hex]["RGB"]["G"]=strtonum("0x"ma[2])
    ac[hex]["RGB"]["B"]=strtonum("0x"ma[3])
    ac[hex]["HEX"]["R"]=ma[1]
    ac[hex]["HEX"]["G"]=ma[2]
    ac[hex]["HEX"]["B"]=ma[3]

    if (ma[4] ~ /./) {
      ac[hex]["RGB"]["A"]=strtonum("0x"ma[4])
      ac[hex]["HEX"]["A"]=ma[4]
    } else {
      ac[hex]["RGB"]["A"]="255"
      ac[hex]["HEX"]["A"]="FF"
    }

    return 0
  } else {
    return 1
  }
}

function isdark(c, darkness) {
  darkness = (1-(0.299*ac[c]["RGB"]["R"] + 0.587*ac[c]["RGB"]["G"] + 0.114*ac[c]["RGB"]["B"])/255)
  if(darkness<0.5){
    return 0
    } else {
    return 1
  }
}

function mix(c1, c2, ratio, iRatio,r,g,b,a,hex) {
  if (ac[c1]["HEX"]["R"] !~ /./) {addcolor(c1)}
  if (ac[c2]["HEX"]["R"] !~ /./) {addcolor(c2)}
  if ( ratio > 1 ) ratio = 1
  else if ( ratio < 0 ) ratio = 0
  iRatio = 1.0 - ratio

  r = ((ac[c1]["RGB"]["R"] * iRatio) + (ac[c2]["RGB"]["R"] * ratio))
  g = ((ac[c1]["RGB"]["G"] * iRatio) + (ac[c2]["RGB"]["G"] * ratio))
  b = ((ac[c1]["RGB"]["B"] * iRatio) + (ac[c2]["RGB"]["B"] * ratio))

  hex = sprintf("#%02X%02X%02X",r,g,b)

  if ((length(c1)>7) || (length(c2)>7)) {

    if ((length(c1)>7) && (length(c2)>7)) {
      a = ((ac[c1]["RGB"]["A"] * iRatio) + (ac[c2]["RGB"]["A"] * ratio))
    }
    else if (length(c1)>7) {
      a = ac[c1]["RGB"]["A"]
    }
    else
      a = ac[c2]["RGB"]["A"]

    hex = hex sprintf("%02X",a)
  }

  addcolor(hex)
  return hex
}

function more(c, ratio) {
  if (ac[c]["HEX"]["R"] !~ /./) {addcolor(c)}
  if (isdark(c)) {
    return darker(c,ratio)
  } else {
    return lighter(c,ratio)
  }
}

function less(c, ratio) {
  if (ac[c]["HEX"]["R"] !~ /./) {addcolor(c)}
  if (isdark(c)) {
    return lighter(c,ratio)
  } else {
    return darker(c,ratio)
  }
}

function darker(c,ratio) {
  return mix(c,"#000000",ratio)
}

function lighter(c,ratio) {
  return mix(c,"#FFFFFF",ratio)
}

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
EOB
}

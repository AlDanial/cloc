/*
Exerpt from
  https://github.com/StoneCypher/short_offer/raw/main/src/peg/sdp_parser.pegjs
*/



RawDocument
  = Offer
  / Answer
  / UnknownTerminatingString         // junk



Digit
  = [0-9]



// Decimal
//   = d:Digit+ { return BigInt(d.join(''), 10); }



Hex
  = [0-9a-fA-F]



Hex2
  = a:Hex b:Hex { return `${a}${b}`; }



Hex4
  = a:Hex b:Hex c:Hex d:Hex
  { return [a,b,c,d].join(''); }



Hex8
  = a:Hex b:Hex c:Hex d:Hex e:Hex f:Hex g:Hex h:Hex
  { return [a,b,c,d,e,f,g,h].join(''); }



Hex12
  = a:Hex b:Hex c:Hex d:Hex e:Hex f:Hex g:Hex h:Hex i:Hex j:Hex k:Hex l:Hex
  { return [a,b,c,d,e,f,g,h,i,j,k,l].join(''); }

// truncated

/*
Exerpt from
  https://github.com/StoneCypher/short_offer/raw/main/src/peg/sdp_parser.pegjs
*/


CHex64
  = a:Hex2 ':' b:Hex2 ':' c:Hex2 ':' d:Hex2 ':' e:Hex2 ':' f:Hex2 ':' g:Hex2 ':' h:Hex2 ':'
    i:Hex2 ':' j:Hex2 ':' k:Hex2 ':' l:Hex2 ':' m:Hex2 ':' n:Hex2 ':' o:Hex2 ':' p:Hex2 ':'
    q:Hex2 ':' r:Hex2 ':' s:Hex2 ':' t:Hex2 ':' u:Hex2 ':' v:Hex2 ':' w:Hex2 ':' x:Hex2 ':'
    y:Hex2 ':' z:Hex2 ':' A:Hex2 ':' B:Hex2 ':' C:Hex2 ':' D:Hex2 ':' E:Hex2 ':' F:Hex2
  { return [ a,b,c,d,e,f,g,h, i,j,k,l,m,n,o,p, q,r,s,t,u,v,w,x, y,z,A,B,C,D,E,F ].join(''); }



IceChar
  = [0-9a-zA-Z/+]



IceChar4
  = a:IceChar b:IceChar c:IceChar d:IceChar
  { return [a,b,c,d].join(''); }



IceChar8
  = a:IceChar b:IceChar c:IceChar d:IceChar e:IceChar f:IceChar
    g:IceChar h:IceChar
  { return [a,b,c,d,e,f,g,h].join(''); }



IceChar22
  = a:IceChar b:IceChar // c:IceChar d:IceChar e:IceChar f:IceChar
    g:IceChar h:IceChar // i:IceChar j:IceChar k:IceChar l:IceChar
    m:IceChar n:IceChar // o:IceChar p:IceChar q:IceChar r:IceChar
    s:IceChar t:IceChar // u:IceChar v:IceChar
  { return [a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v].join(''); }



// IceChar24
//   = a:IceChar b:IceChar c:IceChar d:IceChar e:IceChar f:IceChar
//     g:IceChar h:IceChar i:IceChar j:IceChar k:IceChar l:IceChar
//     m:IceChar n:IceChar o:IceChar p:IceChar q:IceChar r:IceChar
    s:IceChar t:IceChar u:IceChar v:IceChar w:IceChar x:IceChar
  { return [a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x].join(''); }

// truncated

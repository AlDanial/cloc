:< first 120 lines of https://raw.githubusercontent.com/urbit/arvo/master/sys/arvo.hoon
::::::  ::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::  ::::::    Postface                              ::::::
::::::  ::::::::::::::::::::::::::::::::::::::::::::::::::::::
=>  +7
~>  %slog.[0 leaf+"%arvo-assembly"]
::::::  ::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::  ::::::    volume 3, Arvo models and skeleton    ::::::
::::::  ::::::::::::::::::::::::::::::::::::::::::::::::::::::
=>
~%  %hex  +  ~
|%
++  arch  {fil/(unit @uvI) dir/(map @ta $~)}            ::  fundamental node
++  arvo  (wind {p/term q/mill} mill)                   ::  arvo card
++  beam  {{p/ship q/desk r/case} s/path}               ::  global name
++  beak  {p/ship q/desk r/case}                        ::  garnish with beak
++  bone  @ud                                           ::  opaque duct
++  case                                                ::  version
          $%  {$da p/@da}                               ::  date
              {$tas p/@tas}                             ::  label
              {$ud p/@ud}                               ::  sequence
          ==                                            ::
++  desk  @tas                                          ::  ship desk case spur
++  cage  (cask vase)                                   ::  global metadata
++  cask  |*(a/mold (pair mark a))                      ::  global data
++  cuff                                                ::  permissions
          $:  p/(unit (set monk))                       ::  can be read by
              q/(set monk)                              ::  caused or created by
          ==                                            ::
++  curd  {p/@tas q/*}                                  ::  typeless card
++  duct  (list wire)                                   ::  causal history
++  hypo  |*(a/mold (pair type a))                      ::  type associated
++  hobo  |*  a/mold                                    ::  kiss wrapper
          $?  $%  {$soft p/*}                           ::
              ==                                        ::
              a                                         ::
          ==                                            ::
++  kirk  (unit (set monk))                             ::  audience
++  lens                                                ::  observation core
  $_  ^?                                                ::
  |%  ++  u  *(unit (unit $~))                          ::  existence
      ++  v  *(unit (unit cage))                        ::  full history
      ++  w  *(unit (unit (unit cage)))                 ::  latest diff
      ++  x  *(unit (unit cage))                        ::  data at path
      ++  y  *(unit (unit arch))                        ::  directory
      ++  z  *(unit (unit cage))                        ::  current subtree
  --                                                    ::
++  marc                                                ::  structured mark
  $@  mark                                              ::  plain mark
  $%  {$tabl p/(list (pair marc marc))}                 ::  map
  ==                                                    ::
++  mark  @tas                                          ::  content type
++  mash  |=(* (mass +<))                               ::  producing mass
++  mass  (pair cord (each noun (list mash)))           ::  memory usage  
++  mill  (each vase milt)                              ::  vase+metavase
++  milt  {p/* q/*}                                     ::  metavase
++  monk  (each ship {p/@tas q/@ta})                    ::  general identity
++  muse  {p/@tas q/duct r/arvo}                        ::  sourced move
++  move  {p/duct q/arvo}                               ::  arvo move
++  ovum  {p/wire q/curd}                               ::  typeless ovum
++  pane  (list {p/@tas q/vase})                        ::  kernel modules
++  pone  (list {p/@tas q/vise})                        ::  kernel modules old
++  ship  @p                                            ::  network identity
++  sink  (trel bone ship path)                         ::  subscription
++  sley  $-  {* (unit (set monk)) term beam}           ::  namespace function
          (unit (unit cage))                            ::
++  slyd  $-  {* (unit (set monk)) term beam}           ::  super advanced
          (unit (unit (cask)))                          ::
++  slyt  $-({* *} (unit (unit)))                       ::  old namespace
++  vile                                                ::  reflexive constants
          $:  typ/type                                  ::  -:!>(*type)
              duc/type                                  ::  -:!>(*duct)
              pah/type                                  ::  -:!>(*path)
              mev/type                                  ::  -:!>([%meta *vase])
          ==                                            ::
++  wind                                                ::  new kernel action
          |*  {a/mold b/mold}                           ::  forward+reverse
          $%  {$pass p/path q/a}                        ::  advance
              {$slip p/a}                               ::  lateral
              {$give p/b}                               ::  retreat
          ==                                            ::
++  wire  path                                          ::  event pretext
++  sloy
  !:
  |=  sod/slyd
  ^-  slyt
  |=  {ref/* raw/*}
  =+  pux=((soft path) raw)
  ?~  pux  ~
  ?.  ?=({@ @ @ @ *} u.pux)  ~
  =+  :*  hyr=(slay i.u.pux)
          fal=(slay i.t.u.pux)
          dyc=(slay i.t.t.u.pux)
          ved=(slay i.t.t.t.u.pux)
          tyl=t.t.t.t.u.pux
      ==
  ?.  ?=({$~ $$ $tas @} hyr)  ~
  ?.  ?=({$~ $$ $p @} fal)  ~
  ?.  ?=({$~ $$ $tas @} dyc)  ~
  ?.  ?=(^ ved)  ~
  =+  ron=q.p.u.hyr
  =+  bed=[[q.p.u.fal q.p.u.dyc (case p.u.ved)] (flop tyl)]
  =+  bop=(sod ref ~ ron bed)
  ?~  bop  ~
  ?~  u.bop  [~ ~]
  [~ ~ +.q.u.u.bop]
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::                section 3bE, Arvo core                ::
::
++  vent                                                ::  vane core
  |=  {lal/@tas vil/vile bud/vase sew/(pair worm vase)}
  ~%  %vent  +>+  ~
  |%
  ++  ruck                                              ::  update vase
    |=  {pax/path txt/@ta}
    ^+  +>
    =-  ?:(?=($| -.res) ((slog p.res) +>.$) p.res)
    ^=  res  %-  mule  |.
    =+  arg=[~2000.1.1 0 =>(~ |~(* ~))]
    =+  rig=(slym q.sew arg)

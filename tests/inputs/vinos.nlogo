; https://codebase.helmholtz.cloud/mussel/netlogo-northsea-species/-/blob/main/netlogo/vinos.nlogo
; SPDX-FileCopyrightText: 2022-2023 Universität Hamburg (UHH)
; SPDX-FileCopyrightText: 2022-2023 Helmholtz-Zentrum hereon GmbH (Hereon)
; SPDX-License-Identifier: Apache-2.0
;
; SPDX-FileContributor: Carsten Lemmen <carsten.lemmen@hereon.de>
; SPDX-FileContributor: Sascha Hokamp <sascha.hokamp@uni-hamburg.de>
; SPDX-FileContributor: Jieun Seo <jieun.seo@studium.uni-hamburg.de>

extensions [
  gis
  csv
  profiler
  palette
  bitmap
]

__includes [
  "include/geodata.nls"
  "include/calendar.nls"
  "include/gear.nls"
  "include/plot.nls"
  "include/utilities.nls"
  "include/boat.nls"
  "include/view.nls"
  "include/prey.nls"
  "include/port.nls"
]

; breed [gears gear] ; defined in gear.nls
; breed [boats boat] ; defined in boat.nls
; breed [legends legend] ; defined in view.nls
; breed [preys prey] ; defined in prey.nls
; breed [ports port] ; defined in port.nls

breed [actions action]

actions-own [
  action-patch                      ; targeted patch id
  action-gain                        ; gain for the fishing trip of the boat
  action-gear
]

globals [
  navigable-depth                    ; minimum depth where a boat can navigate
  min-fresh-catch                    ; wether the boat decides to go back to harbor, maybe change name

  sum-ports-total-landings-kg        ; overall sum of total landings per period
  percentage-landings-kg             ; percentage of other landing over total landings per period
  sum-ports-crangon-landings-euro    ; overall sum of landings of crangon per period in EUR 2015
  sum-ports-platessa-landings-euro   ; overall sum of landings of platessa per period in EUR 2015
  sum-ports-solea-landings-euro      ; overall sum of landings of solea per period in EUR 2015
  sum-ports-crangon-landings-kg      ; overall sum of landings of crangon per period in kg
  sum-ports-platessa-landings-kg     ; overall sum of landings of platessa per period in kg
  sum-ports-solea-landings-kg        ; overall sum of landings of solea per period in kg
  sum-boats                        ; overall boats of all ports

  owf-dataset                        ; Off-shore wind farms

  year month day                     ; time frame
  day-of-year
  days-in-months

  home-ports                 ; agentset of breed ports
  ;favorite-landing-ports     ; agentset of breed ports

  view-legend-n
  view-legend-thresholds
  date-patch
]

patches-own [
  fish-biomass                    ; vektor of biomass of the fish species


  fishing-effort-hours                   ; fishing effort in hours
  crangon-summer                         ; data from TI
  crangon-winter
  platessa-summer
  platessa-winter
  solea-summer
  solea-winter

  fish-abundance

  pollution-exceedance
  depth
  owf-fraction
  accessible?             ; false if not accessible to fishery, i.e. close to port, too shallow, restricted area
  plaice-box?

  patch-prey-names
]
